defmodule Oddish.Cattle do
  @moduledoc """
  The Cattle context.
  """

  import Ecto.Query, warn: false
  alias Oddish.Repo

  alias Oddish.Cattle.Bovine
  alias Oddish.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any bovine changes.

  The broadcasted messages match the pattern:

    * {:created, %Bovine{}}
    * {:updated, %Bovine{}}
    * {:deleted, %Bovine{}}

  """
  def subscribe_bovines(%Scope{} = scope) do
    key = scope.organization.id

    Phoenix.PubSub.subscribe(Oddish.PubSub, "organization:#{key}:bovines")
  end

  defp broadcast_bovine(%Scope{} = scope, message) do
    key = scope.organization.id

    Phoenix.PubSub.broadcast(Oddish.PubSub, "organization:#{key}:bovines", message)
  end

  @doc """
  Returns the list of bovines.

  ## Examples

      iex> list_bovines(scope)
      [%Bovine{}, ...]

  """
  def list_bovines(%Scope{} = scope) do
    Repo.all_by(Bovine, org_id: scope.organization.id)
  end

  def list_cows(%Scope{} = scope) do
    Repo.all_by(Bovine, org_id: scope.organization.id, gender: :female)
  end

  @doc """
  Gets a single bovine.

  Raises `Ecto.NoResultsError` if the Bovine does not exist.

  ## Examples

      iex> get_bovine!(scope, 123)
      %Bovine{}

      iex> get_bovine!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_bovine!(%Scope{} = scope, id) do
    Repo.get_by!(Bovine, id: id, org_id: scope.organization.id)
  end

  @doc """
  Creates a bovine.

  ## Examples

      iex> create_bovine(scope, %{field: value})
      {:ok, %Bovine{}}

      iex> create_bovine(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bovine(%Scope{} = scope, attrs) do
    with {:ok, bovine = %Bovine{}} <-
           %Bovine{}
           |> Bovine.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_bovine(scope, {:created, bovine})
      {:ok, bovine}
    end
  end

  @doc """
  Updates a bovine.

  ## Examples

      iex> update_bovine(scope, bovine, %{field: new_value})
      {:ok, %Bovine{}}

      iex> update_bovine(scope, bovine, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bovine(%Scope{} = scope, %Bovine{} = bovine, attrs) do
    true = bovine.org_id == scope.organization.id

    with {:ok, bovine = %Bovine{}} <-
           bovine
           |> Bovine.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_bovine(scope, {:updated, bovine})
      {:ok, bovine}
    end
  end

  @doc """
  Deletes a bovine.

  ## Examples

      iex> delete_bovine(scope, bovine)
      {:ok, %Bovine{}}

      iex> delete_bovine(scope, bovine)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bovine(%Scope{} = scope, %Bovine{} = bovine) do
    true = bovine.org_id == scope.organization.id

    with {:ok, bovine = %Bovine{}} <-
           Repo.delete(bovine) do
      broadcast_bovine(scope, {:deleted, bovine})
      {:ok, bovine}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bovine changes.

  ## Examples

      iex> change_bovine(scope, bovine)
      %Ecto.Changeset{data: %Bovine{}}

  """
  def change_bovine(%Scope{} = scope, %Bovine{} = bovine, attrs \\ %{}) do
    true = bovine.org_id == scope.organization.id

    Bovine.changeset(bovine, attrs, scope)
  end
end
