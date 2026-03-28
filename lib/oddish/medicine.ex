defmodule Oddish.Medicine do
  @moduledoc """
  The Medicine context.
  """

  import Ecto.Query, warn: false
  alias Oddish.Repo

  alias Oddish.Medicine.Vet
  alias Oddish.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any vet changes.

  The broadcasted messages match the pattern:

    * {:created, %Vet{}}
    * {:updated, %Vet{}}
    * {:deleted, %Vet{}}

  """
  def subscribe_vets(%Scope{} = scope) do
    key = scope.organization.id

    Phoenix.PubSub.subscribe(Oddish.PubSub, "organization:#{key}:vets")
  end

  defp broadcast_vet(%Scope{} = scope, message) do
    key = scope.organization.id

    Phoenix.PubSub.broadcast(Oddish.PubSub, "organization:#{key}:vets", message)
  end

  @doc """
  Returns the list of vets.

  ## Examples

      iex> list_vets(scope)
      [%Vet{}, ...]

  """
  def list_vets(%Scope{} = scope) do
    Repo.all_by(Vet, org_id: scope.organization.id)
  end

  @doc """
  Gets a single vet.

  Raises `Ecto.NoResultsError` if the Vet does not exist.

  ## Examples

      iex> get_vet!(scope, 123)
      %Vet{}

      iex> get_vet!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_vet!(%Scope{} = scope, id) do
    Repo.get_by!(Vet, id: id, org_id: scope.organization.id)
  end

  @doc """
  Creates a vet.

  ## Examples

      iex> create_vet(scope, %{field: value})
      {:ok, %Vet{}}

      iex> create_vet(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vet(%Scope{} = scope, attrs) do
    with {:ok, vet = %Vet{}} <-
           %Vet{}
           |> Vet.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_vet(scope, {:created, vet})
      {:ok, vet}
    end
  end

  @doc """
  Updates a vet.

  ## Examples

      iex> update_vet(scope, vet, %{field: new_value})
      {:ok, %Vet{}}

      iex> update_vet(scope, vet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vet(%Scope{} = scope, %Vet{} = vet, attrs) do
    true = vet.org_id == scope.organization.id

    with {:ok, vet = %Vet{}} <-
           vet
           |> Vet.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_vet(scope, {:updated, vet})
      {:ok, vet}
    end
  end

  @doc """
  Deletes a vet.

  ## Examples

      iex> delete_vet(scope, vet)
      {:ok, %Vet{}}

      iex> delete_vet(scope, vet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vet(%Scope{} = scope, %Vet{} = vet) do
    true = vet.org_id == scope.organization.id

    with {:ok, vet = %Vet{}} <-
           Repo.delete(vet) do
      broadcast_vet(scope, {:deleted, vet})
      {:ok, vet}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vet changes.

  ## Examples

      iex> change_vet(scope, vet)
      %Ecto.Changeset{data: %Vet{}}

  """
  def change_vet(%Scope{} = scope, %Vet{} = vet, attrs \\ %{}) do
    true = vet.org_id == scope.organization.id

    Vet.changeset(vet, attrs, scope)
  end

  alias Oddish.Medicine.Procedure
  alias Oddish.Accounts.Scope

  @default_procedures [
    %{name: "Inseminação", kind: :iatf},
    %{name: "Exame de gestação", kind: :iatf}
  ]

  @doc """
  Sets up default records (like common procedures) for a newly created organization.
  """
  def setup_organization_defaults(%Scope{} = scope) do
    for attrs <- @default_procedures do
      create_procedure(scope, attrs)
    end

    :ok
  end

  @doc """
  Subscribes to scoped notifications about any procedure changes.

  The broadcasted messages match the pattern:

    * {:created, %Procedure{}}
    * {:updated, %Procedure{}}
    * {:deleted, %Procedure{}}

  """
  def subscribe_procedures(%Scope{} = scope) do
    key = scope.organization.id

    Phoenix.PubSub.subscribe(Oddish.PubSub, "organization:#{key}:procedures")
  end

  defp broadcast_procedure(%Scope{} = scope, message) do
    key = scope.organization.id

    Phoenix.PubSub.broadcast(Oddish.PubSub, "organization:#{key}:procedures", message)
  end

  @doc """
  Returns the list of procedures.

  ## Examples

      iex> list_procedures(scope)
      [%Procedure{}, ...]

  """
  def list_procedures(%Scope{} = scope) do
    Repo.all_by(Procedure, org_id: scope.organization.id)
  end

  @doc """
  Gets a single procedure.

  Raises `Ecto.NoResultsError` if the Procedure does not exist.

  ## Examples

      iex> get_procedure!(scope, 123)
      %Procedure{}

      iex> get_procedure!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_procedure!(%Scope{} = scope, id) do
    Repo.get_by!(Procedure, id: id, org_id: scope.organization.id)
  end

  @doc """
  Creates a procedure.

  ## Examples

      iex> create_procedure(scope, %{field: value})
      {:ok, %Procedure{}}

      iex> create_procedure(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_procedure(%Scope{} = scope, attrs) do
    with {:ok, procedure = %Procedure{}} <-
           %Procedure{}
           |> Procedure.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_procedure(scope, {:created, procedure})
      {:ok, procedure}
    end
  end

  @doc """
  Updates a procedure.

  ## Examples

      iex> update_procedure(scope, procedure, %{field: new_value})
      {:ok, %Procedure{}}

      iex> update_procedure(scope, procedure, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_procedure(%Scope{} = scope, %Procedure{} = procedure, attrs) do
    true = procedure.org_id == scope.organization.id

    with {:ok, procedure = %Procedure{}} <-
           procedure
           |> Procedure.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_procedure(scope, {:updated, procedure})
      {:ok, procedure}
    end
  end

  @doc """
  Deletes a procedure.

  ## Examples

      iex> delete_procedure(scope, procedure)
      {:ok, %Procedure{}}

      iex> delete_procedure(scope, procedure)
      {:error, %Ecto.Changeset{}}

  """
  def delete_procedure(%Scope{} = scope, %Procedure{} = procedure) do
    true = procedure.org_id == scope.organization.id

    with {:ok, procedure = %Procedure{}} <-
           Repo.delete(procedure) do
      broadcast_procedure(scope, {:deleted, procedure})
      {:ok, procedure}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking procedure changes.

  ## Examples

      iex> change_procedure(scope, procedure)
      %Ecto.Changeset{data: %Procedure{}}

  """
  def change_procedure(%Scope{} = scope, %Procedure{} = procedure, attrs \\ %{}) do
    true = procedure.org_id == scope.organization.id

    Procedure.changeset(procedure, attrs, scope)
  end

  alias Oddish.Medicine.Visit
  alias Oddish.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any visit changes.

  The broadcasted messages match the pattern:

    * {:created, %Visit{}}
    * {:updated, %Visit{}}
    * {:deleted, %Visit{}}

  """
  def subscribe_visits(%Scope{} = scope) do
    key = scope.organization.id

    Phoenix.PubSub.subscribe(Oddish.PubSub, "organization:#{key}:visits")
  end

  defp broadcast_visit(%Scope{} = scope, message) do
    key = scope.organization.id

    Phoenix.PubSub.broadcast(Oddish.PubSub, "organization:#{key}:visits", message)
  end

  @doc """
  Returns the list of visits.

  ## Examples

      iex> list_visits(scope)
      [%Visit{}, ...]

  """
  def list_visits(%Scope{} = scope) do
    Repo.all_by(Visit, org_id: scope.organization.id)
    |> Repo.preload([:bovines, :vet, :procedure])
  end

  @doc """
  Gets a single visit.

  Raises `Ecto.NoResultsError` if the Visit does not exist.

  ## Examples

      iex> get_visit!(scope, 123)
      %Visit{}

      iex> get_visit!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_visit!(%Scope{} = scope, id) do
    Repo.get_by!(Visit, id: id, org_id: scope.organization.id)
    |> Repo.preload([:bovines, :vet, :procedure])
  end

  @doc """
  Creates a visit.

  ## Examples

      iex> create_visit(scope, %{field: value})
      {:ok, %Visit{}}

      iex> create_visit(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_visit(%Scope{} = scope, attrs) do
    bovine_ids =
      Map.get(attrs, "bovine_ids", Map.get(attrs, :bovine_ids, [])) |> Enum.reject(&(&1 == ""))

    bovines =
      Repo.all(
        from b in Oddish.Cattle.Bovine,
          where: b.id in ^bovine_ids and b.org_id == ^scope.organization.id
      )

    changeset =
      %Visit{}
      |> Visit.changeset(attrs, scope)
      |> Ecto.Changeset.put_assoc(:bovines, bovines)

    with {:ok, visit = %Visit{}} <- Repo.insert(changeset) do
      visit = Repo.preload(visit, [:bovines, :vet, :procedure])
      broadcast_visit(scope, {:created, visit})
      {:ok, visit}
    end
  end

  @doc """
  Updates a visit.

  ## Examples

      iex> update_visit(scope, visit, %{field: new_value})
      {:ok, %Visit{}}

      iex> update_visit(scope, visit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_visit(%Scope{} = scope, %Visit{} = visit, attrs) do
    true = visit.org_id == scope.organization.id

    visit = Repo.preload(visit, :bovines)
    changeset = Visit.changeset(visit, attrs, scope)

    changeset =
      if Map.has_key?(attrs, "bovine_ids") or Map.has_key?(attrs, :bovine_ids) do
        bovine_ids =
          Map.get(attrs, "bovine_ids", Map.get(attrs, :bovine_ids, []))
          |> Enum.reject(&(&1 == ""))

        bovines =
          Repo.all(
            from b in Oddish.Cattle.Bovine,
              where: b.id in ^bovine_ids and b.org_id == ^scope.organization.id
          )

        Ecto.Changeset.put_assoc(changeset, :bovines, bovines)
      else
        changeset
      end

    with {:ok, visit = %Visit{}} <- Repo.update(changeset) do
      visit = Repo.preload(visit, [:bovines, :vet, :procedure])
      broadcast_visit(scope, {:updated, visit})
      {:ok, visit}
    end
  end

  @doc """
  Deletes a visit.

  ## Examples

      iex> delete_visit(scope, visit)
      {:ok, %Visit{}}

      iex> delete_visit(scope, visit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_visit(%Scope{} = scope, %Visit{} = visit) do
    true = visit.org_id == scope.organization.id

    with {:ok, visit = %Visit{}} <-
           Repo.delete(visit) do
      broadcast_visit(scope, {:deleted, visit})
      {:ok, visit}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking visit changes.

  ## Examples

      iex> change_visit(scope, visit)
      %Ecto.Changeset{data: %Visit{}}

  """
  def change_visit(%Scope{} = scope, %Visit{} = visit, attrs \\ %{}) do
    true = visit.org_id == scope.organization.id

    visit = Repo.preload(visit, :bovines)
    Visit.changeset(visit, attrs, scope)
  end
end
