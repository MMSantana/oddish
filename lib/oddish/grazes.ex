defmodule Oddish.Grazes do
  @moduledoc """
  The Grazes context.
  """

  import Ecto.Query, warn: false
  alias Oddish.Repo

  alias Oddish.Grazes.Graze
  alias Oddish.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any graze changes.

  The broadcasted messages match the pattern:

    * {:created, %Graze{}}
    * {:updated, %Graze{}}
    * {:deleted, %Graze{}}

  """
  def subscribe_grazes(%Scope{} = scope) do
    key = scope.organization.id

    Phoenix.PubSub.subscribe(Oddish.PubSub, "organization:#{key}:grazes")
  end

  defp broadcast_graze(%Scope{} = scope, message) do
    key = scope.organization.id

    Phoenix.PubSub.broadcast(Oddish.PubSub, "organization:#{key}:grazes", message)
  end

  @doc """
  Returns the list of grazes.

  ## Examples

      iex> list_grazes(scope)
      [%Graze{}, ...]

  """
  def list_grazes(%Scope{} = scope) do
    Repo.all_by(Graze, org_id: scope.organization.id)
  end

  def list_grazes(%Scope{} = scope, filters \\ []) do
    Graze
    |> where(org_id: ^scope.organization.id)
    |> maybe_filter_by_pack(filters[:pack_id])
    |> maybe_filter_by_solta(filters[:solta_id])
    |> maybe_filter_by_status(filters[:status])
    |> Repo.all()
  end

  defp maybe_filter_by_pack(query, nil), do: query
  defp maybe_filter_by_pack(query, id), do: where(query, pack_id: ^id)

  defp maybe_filter_by_solta(query, nil), do: query
  defp maybe_filter_by_solta(query, id), do: where(query, solta_id: ^id)

  defp maybe_filter_by_status(query, nil), do: query
  defp maybe_filter_by_status(query, status), do: where(query, status: ^status)

  def list_grazes_by_status(%Scope{} = scope, status) do
    Repo.all_by(Graze, org_id: scope.organization.id, status: status)
    |> Repo.preload(:solta)
  end

  @doc """
  Gets a single graze.

  Raises `Ecto.NoResultsError` if the Graze does not exist.

  ## Examples

      iex> get_graze!(scope, 123)
      %Graze{}

      iex> get_graze!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_graze!(%Scope{} = scope, id) do
    Repo.get_by!(Graze, id: id, org_id: scope.organization.id)
    |> Repo.preload(:solta)
  end

  @doc """
  Creates a graze.

  ## Examples

      iex> create_graze(scope, %{field: value})
      {:ok, %Graze{}}

      iex> create_graze(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_graze(%Scope{} = scope, attrs) do
    with {:ok, graze = %Graze{}} <-
           %Graze{}
           |> Graze.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_graze(scope, {:created, graze})
      {:ok, graze}
    end
  end

  @doc """
  Updates a graze.

  ## Examples

      iex> update_graze(scope, graze, %{field: new_value})
      {:ok, %Graze{}}

      iex> update_graze(scope, graze, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_graze(%Scope{} = scope, %Graze{} = graze, attrs) do
    true = graze.org_id == scope.organization.id

    with {:ok, graze = %Graze{}} <-
           graze
           |> Graze.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_graze(scope, {:updated, graze})
      {:ok, graze}
    end
  end

  @doc """
  Deletes a graze.

  ## Examples

      iex> delete_graze(scope, graze)
      {:ok, %Graze{}}

      iex> delete_graze(scope, graze)
      {:error, %Ecto.Changeset{}}

  """
  def delete_graze(%Scope{} = scope, %Graze{} = graze) do
    true = graze.org_id == scope.organization.id

    with {:ok, graze = %Graze{}} <-
           Repo.delete(graze) do
      broadcast_graze(scope, {:deleted, graze})
      {:ok, graze}
    end
  end

  def start_planned_graze(%Scope{} = scope, %Graze{} = graze) do
    true = graze.status == :planned

    update_graze(scope, graze, %{status: :ongoing})
  end

  def end_ongoing_graze(%Scope{} = scope, %Graze{} = graze) do
    true = graze.status == :ongoing

    update_graze(scope, graze, %{status: :finished, end_date: Date.utc_today()})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking graze changes.

  ## Examples

      iex> change_graze(scope, graze)
      %Ecto.Changeset{data: %Graze{}}

  """
  def change_graze(%Scope{} = scope, %Graze{} = graze, attrs \\ %{}) do
    true = graze.org_id == scope.organization.id

    Graze.changeset(graze, attrs, scope)
  end
end
