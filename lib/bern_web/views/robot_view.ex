defmodule BernWeb.RobotView do
  use BernWeb, :view

  @generic %BernWeb.SEO.Generic{}

  def render("robots.txt", %{env: :prod}), do: ""

  def render("robots.txt", %{env: _}) do
    """
    User-agent: *
    Disallow: /
    """
  end

  def render("rss.xml", %{}) do
    BernWeb.Rss.generate(%BernWeb.Rss{
      title: @generic.title,
      author: "Abhishek Tripathi",
      description: @generic.description,
      posts: Bern.Blog.published_posts()
    })
  end
end
