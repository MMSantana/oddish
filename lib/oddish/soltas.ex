defmodule Oddish.Soltas do
  @moduledoc """
  The Soltas context.
  """

  import Ecto.Query, warn: false
  alias Oddish.Repo

  alias Oddish.Soltas.Solta
  alias Oddish.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any solta changes.

  The broadcasted messages match the pattern:

    * {:created, %Solta{}}
    * {:updated, %Solta{}}
    * {:deleted, %Solta{}}

  """
  def subscribe_soltas(%Scope{} = scope) do
    key = scope.organization.id

    Phoenix.PubSub.subscribe(Oddish.PubSub, "organization:#{key}:soltas")
  end

  defp broadcast_solta(%Scope{} = scope, message) do
    key = scope.organization.id

    Phoenix.PubSub.broadcast(Oddish.PubSub, "organization:#{key}:soltas", message)
  end

  @doc """
  Returns the list of soltas.

  ## Examples

      iex> list_soltas(scope)
      [%Solta{}, ...]

  """
  def list_soltas(%Scope{} = scope) do
    Repo.all_by(Solta, org_id: scope.organization.id)
  end

  @doc """
  Gets a single solta.

  Raises `Ecto.NoResultsError` if the Solta does not exist.

  ## Examples

      iex> get_solta!(scope, 123)
      %Solta{}

      iex> get_solta!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_solta!(%Scope{} = scope, id) do
    Repo.get_by!(Solta, id: id, org_id: scope.organization.id)
  end

  @doc """
  Creates a solta.

  ## Examples

      iex> create_solta(scope, %{field: value})
      {:ok, %Solta{}}

      iex> create_solta(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_solta(%Scope{} = scope, attrs) do
    with {:ok, solta = %Solta{}} <-
           %Solta{}
           |> Solta.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_solta(scope, {:created, solta})
      {:ok, solta}
    end
  end

  @doc """
  Updates a solta.

  ## Examples

      iex> update_solta(scope, solta, %{field: new_value})
      {:ok, %Solta{}}

      iex> update_solta(scope, solta, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_solta(%Scope{} = scope, %Solta{} = solta, attrs) do
    true = solta.org_id == scope.organization.id

    with {:ok, solta = %Solta{}} <-
           solta
           |> Solta.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_solta(scope, {:updated, solta})
      {:ok, solta}
    end
  end

  @doc """
  Deletes a solta.

  ## Examples

      iex> delete_solta(scope, solta)
      {:ok, %Solta{}}

      iex> delete_solta(scope, solta)
      {:error, %Ecto.Changeset{}}

  """
  def delete_solta(%Scope{} = scope, %Solta{} = solta) do
    true = solta.org_id == scope.organization.id

    with {:ok, solta = %Solta{}} <-
           Repo.delete(solta) do
      broadcast_solta(scope, {:deleted, solta})
      {:ok, solta}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking solta changes.

  ## Examples

      iex> change_solta(scope, solta)
      %Ecto.Changeset{data: %Solta{}}

  """
  def change_solta(%Scope{} = scope, %Solta{} = solta, attrs \\ %{}) do
    true = solta.org_id == scope.organization.id

    Solta.changeset(solta, attrs, scope)
  end
end
