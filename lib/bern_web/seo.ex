defmodule BernWeb.SEO do
  @moduledoc "You know, juice."

  use SEO, [
    site: SEO.Site.build(
      title_suffix: " · Bernheisel",
      default_title: "David Bernheisel's Blog",
      description: "A blog about development",
      theme_color: "#663399",
      windows_tile_color: "#663399",
      mask_icon_color: "#663399"
    ),
    open_graph: SEO.OpenGraph.build(
      locale: "en_US"
    ),
    twitter: SEO.Twitter.build(
      site: "@bernheisel",
      creator: "@bernheisel"
    )
  ]
end

defimpl SEO.OpenGraph.Build, for: Bern.Blog.Post do
  @endpoint BernWeb.Endpoint
  alias BernWeb.Router.Helpers, as: Routes

  def build(post) do
    SEO.OpenGraph.build(
      title: SEO.Utils.truncate(post.title, 70),
      description: post.description,
      type: :article,
      type_detail: SEO.OpenGraph.Article.build(
        published_time: post.published && post.date,
        author: "David Bernheisel",
        tag: post.tags
      ),
      url: Routes.blog_url(@endpoint, :show, post.id)
    ) |> put_image(post)
  end

  defp put_image(og, post) do
    file = "/images/blog/#{post.id}.png"

    exists? =
      [Application.app_dir(:bern), "/priv/static", file]
      |> Path.join()
      |> File.exists?()

    if exists? do
      %{og |
        image: SEO.OpenGraph.Image.build(
          url: Routes.static_url(@endpoint, file),
          alt: post.title
        )
      }
    else
      og
    end
  end
end

defimpl SEO.Breadcrumb.Build, for: Bern.Blog.Post do
  @endpoint BernWeb.Endpoint
  alias BernWeb.Router.Helpers, as: Routes

  def build(post) do
    SEO.Breadcrumb.List.build([
      %{name: "Posts", item: Routes.blog_url(@endpoint, :index)},
      %{name: post.title, item: Routes.blog_url(@endpoint, :show, post.id)}
    ])
  end
end

defimpl SEO.Twitter.Build, for: Bern.Blog.Post do
  def build(_post) do
    SEO.Twitter.build(card: :summary_large_image)
  end
end

defimpl SEO.Site.Build, for: Bern.Blog.Post do
  def build(post) do
    SEO.Site.build(
      title: SEO.Utils.truncate(post.title, 70),
      description: post.description,
      canonical_url: post.canonical_url
    )
  end
end

defimpl SEO.Unfurl.Build, for: Bern.Blog.Post do
  def build(post) do
    if post.published do
      SEO.Unfurl.build(
        label1: "Reading Time",
        data1: format_time(post.reading_time),
        label2: "Published",
        data2: Date.to_iso8601(post.date)
      )
    end
  end

  defp format_time(length), do: "#{length} minutes"
end
