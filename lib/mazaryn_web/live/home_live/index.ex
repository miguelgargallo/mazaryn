defmodule MazarynWeb.HomeLive.Index do
  use MazarynWeb, :live_view

  alias Core.PostClient, as: PostClient

  import MazarynWeb.Live.Helper
  alias MazarynWeb.Component.SelectLive
  alias Home.Post
  alias Account.Users
  require Logger

  # case reload home page
  @impl true
  def mount(_params, %{"user_id" => user_id} = _session, socket) do
    Logger.info(user_id: user_id)
    {:ok, do_mount(user_id, socket)}
  end

  # case redirect form login, signup
  @impl true
  def mount(_params, %{"session_uuid" => session_uuid} = _session, socket) do
    {:ok, do_mount(get_user_id(session_uuid), socket)}
  end

  defp do_mount(user_id, socket) do
    post_changeset = Post.changeset(%Post{})

    socket
    |> assign(post_changeset: post_changeset)
    |> assign(user: Users.one_by_email(user_id))
    |> assign(posts: get_post(user_id))
  end

  @impl true
  def handle_event("messages", _param, socket) do
    random_id = "/messages/" <> "1"
    {:noreply, push_redirect(socket, to: random_id)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  require Logger

  defp get_post(user_id) do
    post = Post.posts_from_user_following(user_id)
    Logger.info(post)
    post
  end

  defp get_post, do: PostClient.get_posts()
end
