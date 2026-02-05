defmodule Oddish.Packs do
  @moduledoc """
  The Packs context.
  """

  import Ecto.Query, warn: false
  alias Oddish.Repo

  alias Oddish.Packs.Pack
  alias Oddish.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any pack changes.

  The broadcasted messages match the pattern:

    * {:created, %Pack{}}
    * {:updated, %Pack{}}
    * {:deleted, %Pack{}}

  """
  def subscribe_packs(%Scope{} = scope) do
    key = scope.organization.id

    Phoenix.PubSub.subscribe(Oddish.PubSub, "organization:#{key}:packs")
  end

  defp broadcast_pack(%Scope{} = scope, message) do
    key = scope.organization.id

    Phoenix.PubSub.broadcast(Oddish.PubSub, "organization:#{key}:packs", message)
  end

  @doc """
  Returns the list of packs.

  ## Examples

      iex> list_packs(scope)
      [%Pack{}, ...]

  """
  def list_packs(%Scope{} = scope) do
    Repo.all_by(Pack, org_id: scope.organization.id)
  end

  @doc """
  Gets a single pack.

  Raises `Ecto.NoResultsError` if the Pack does not exist.

  ## Examples

      iex> get_pack!(scope, 123)
      %Pack{}

      iex> get_pack!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_pack!(%Scope{} = scope, id) do
    Repo.get_by!(Pack, id: id, org_id: scope.organization.id)
  end

  @doc """
  Creates a pack.

  ## Examples

      iex> create_pack(scope, %{field: value})
      {:ok, %Pack{}}

      iex> create_pack(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pack(%Scope{} = scope, attrs) do
    with {:ok, pack = %Pack{}} <-
           %Pack{}
           |> Pack.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_pack(scope, {:created, pack})
      {:ok, pack}
    end
  end

  @doc """
  Updates a pack.

  ## Examples

      iex> update_pack(scope, pack, %{field: new_value})
      {:ok, %Pack{}}

      iex> update_pack(scope, pack, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pack(%Scope{} = scope, %Pack{} = pack, attrs) do
    true = pack.org_id == scope.organization.id

    with {:ok, pack = %Pack{}} <-
           pack
           |> Pack.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_pack(scope, {:updated, pack})
      {:ok, pack}
    end
  end

  @doc """
  Deletes a pack.

  ## Examples

      iex> delete_pack(scope, pack)
      {:ok, %Pack{}}

      iex> delete_pack(scope, pack)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pack(%Scope{} = scope, %Pack{} = pack) do
    true = pack.org_id == scope.organization.id

    with {:ok, pack = %Pack{}} <-
           Repo.delete(pack) do
      broadcast_pack(scope, {:deleted, pack})
      {:ok, pack}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pack changes.

  ## Examples

      iex> change_pack(scope, pack)
      %Ecto.Changeset{data: %Pack{}}

  """
  def change_pack(%Scope{} = scope, %Pack{} = pack, attrs \\ %{}) do
    true = pack.org_id == scope.organization.id

    Pack.changeset(pack, attrs, scope)
  end
end
