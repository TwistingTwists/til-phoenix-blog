%{
  title: "HTTP Streaming from url (video) to S3 with low memory footprint",
  tags: ["finch", "http-streaming"],
  published: false,
  discussion_url: "",
  description: """
  Streaming with low memory footprint.
  """
}
---

First of all, there is a lot of code in this blogpost that is picked from 1-2 sources. Like [this](https://github.com/wojtekmach/req/issues/82#issuecomment-1083656956), [this](https://scoutapm.com/blog/how-to-use-mint-an-awesome-http-library-for-elixir-part-02) and [this](https://gist.github.com/hubertlepicki/7be1d5c1f396c7508b153a4a39a542ef#file-http_streamer-ex-L19).

Here is the code. It streams the video file present at url like, https://ab.c/ads.mp4 to s3 object with memory footprint as low as 10Mb.


```elixir
defmodule FinchStream do

  def request(req, name, opts \\ []) do
    Stream.resource(
      fn -> start_fun(req, name, opts) end,
      &next_fun/1,
      &after_fun/1
    )
  end

  defp start_fun(req, name, opts) do
    me = self()
    ref = make_ref()

    task =
      Task.async(fn ->
        fun = fn chunk, _acc -> send(me, {:chunk, chunk, ref}) end
        Finch.stream(req, name, nil, fun, opts)
        send(me, {:done, ref})
      end)

    {ref, task}
  end

  defp next_fun({ref, task}) do
    receive do
      {:chunk, chunk, ^ref} -> {[chunk], {ref, task}}
      {:done, ^ref} -> {:halt, {ref, task}}
    end
  end

  defp after_fun({_ref, task}) do
    Task.shutdown(task)
  end

  def run(url, filename \\ "filename-finch_wojtechmak1.mp4") do
    Finch.build(:get, url)
    |> FinchStream.request(RazorNew.Finch)
    |> Stream.drop_while(fn {type, _data} -> type != :data end)
    |> Stream.each(fn {:data, data} -> green("#{byte_size(data)}") end)
    # If not using further steps of uploading to S3, you can use Stream.run to download.
    # |> Stream.run()
    # https://stackoverflow.com/a/53009277 -- do not assume 5 MB to be 5 * 1000 * 1000. Instead, use 1024 as multiplier
    |> chunk_bytes(20 * 1024 * 1024)
    |> ExAws.S3.upload("ex-razor-app", filename)
    |> ExAws.request()
  end



  defp chunk_bytes(enum, bytes) do
    chunk_fun = fn {:data, element}, acc ->
      acc = acc <> element

      if bytes < byte_size(acc) do
        <<head::binary-size(bytes), rest::binary>> = acc
        {:cont, head, rest}
      else
        {:cont, acc}
      end
    end

    after_fun = fn acc ->
      {:cont, acc, ""}
    end

    Stream.chunk_while(enum, "", chunk_fun, after_fun)
  end

end
```

Now, let's break down each function bit by bit.

```elixir

  def request(req, name, opts \\ []) do
    Stream.resource(
      fn -> start_fun(req, name, opts) end,
      &next_fun/1,
      &after_fun/1
    )
  end
```
This uses `[Stream.resource/3](https://hexdocs.pm/elixir/1.14.3/Stream.html#resource/3)` to create a stream. Since streams have inifite elements, they can be created for http clients. That's what the `start_fun/3` is about. Let's see that in great detail.


```elixir

  defp start_fun(req, name, opts) do
    me = self()
    ref = make_ref()

    task =
      Task.async(fn ->
        fun = fn chunk, _acc -> send(me, {:chunk, chunk, ref}) end
        Finch.stream(req, name, nil, fun, opts)
        send(me, {:done, ref})
      end)

    {ref, task}
  end
```

There are quite a few things going on there.


1. `self/0` - gives the pid of current process
2. `make_ref/0` - creates a unique reference ([read more](https://hexdocs.pm/elixir/1.14.3/Kernel.html#make_ref/0))
3. `Task.async/1` - spawns a task which
4. `[Finch.stream/5](https://hexdocs.pm/finch/Finch.html#stream/5)` - streams the request in accumulator via `fun/2` defined just above.

So every time Finch receives some data, it calls `fun/2` which `send`s a message to the process itself which is handled in `next_fun/1`. After `{:chunk,chunk, ref}` message is received, it is passed of simply. It is not accumulated here. It allows the streaming HTTP client to be dumb. Chunk size can be further set in `chunk_bytes/2`. This function puts chunks into a list (accumulator). `Finch.stream/5` continues to send `{:chunk, chunk, ref}` as it continues to more data from url.


All you have to do run this is `FinchStream.run("Your Favourite_url.mp4", "optionalfilename")`
and Boom! your video is going from the url to S3 in the chunks you defined!
