defmodule Account.User do
  @moduledoc """
  Embedded schema to represent Account.User
  """
  use Ecto.Schema

  import Ecto.Changeset

  @optional_fields ~w(
    id
    username
    email
    password
    private
    other_info
    media
    posts
    following
    follower
    blocked
    saved_posts
    notifications
    country
    avatar_url
    banner_url
  )a

  @required_attrs [
    :username,
    :email,
    :password
  ]

  embedded_schema do
    field(:form_disabled, :boolean)
    field(:username, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:private, :boolean)
    field(:other_info, :map)
    field(:media, {:array, :string}, default: [])
    field(:date_created, :utc_datetime)
    field(:date_updated, :utc_datetime)

    field(:posts, {:array, :string}, default: [])
    field(:following, {:array, :string}, default: [])
    field(:follower, {:array, :string}, default: [])
    field(:blocked, {:array, :string}, default: [])
    field(:saved_posts, {:array, :string}, default: [])

    field(:notifications, {:array, :string}, default: [])

    # TODO: ADD to mnesia
    field(:avatar_url, :string, default: "")
    field(:banner_url, :string, default: "")
    field(:country, :string)
  end

  def erl_changeset(
        {:user, username, id, password, email, media, posts, following, follower, blocked,
         saved_posts, other_info, private, date_created, date_updated, avatar_url,
         banner_url} = user
      ) do
    avatar_url =
      case avatar_url do
        :undefined -> nil
        value -> value
      end

    banner_url =
      case banner_url do
        :undefined -> nil
        value -> value
      end

    %__MODULE__{}
    |> cast(
      %{
        username: username,
        id: id,
        password: password,
        email: email,
        media: media,
        posts: posts,
        following: following,
        follower: follower,
        blocked: blocked,
        saved_posts: saved_posts,
        other_info: Enum.into(other_info, %{}),
        private: private,
        date_created: date_created,
        date_updated: date_updated,
        avatar_url: avatar_url,
        banner_url: banner_url
      },
      @optional_fields ++ @required_attrs
    )
    |> validate_required(@required_attrs)
  end

  def erl_changeset(value), do: raise(value)

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password,
      min: 8,
      max: 60,
      message: "Password must be between 8 and 20 characters"
    )
    |> create_password_hash()
  end

  def create_password_hash(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  def create_password_hash(%Ecto.Changeset{} = changeset) do
    password_hash =
      changeset
      |> Ecto.Changeset.get_field(:password)
      |> :erlpass.hash()

    changeset
    |> Ecto.Changeset.put_change(:password, password_hash)
  end

  def build(changeset) do
    apply_action(changeset, :build)
  end
end
