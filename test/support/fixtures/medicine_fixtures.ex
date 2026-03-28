defmodule Oddish.MedicineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Oddish.Medicine` context.
  """

  @doc """
  Generate a vet.
  """
  def vet_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        email: "some email",
        name: "some name",
        telephone: "some telephone"
      })

    {:ok, vet} = Oddish.Medicine.create_vet(scope, attrs)
    vet
  end

  @doc """
  Generate a procedure.
  """
  def procedure_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name",
        kind: :iatf
      })

    {:ok, procedure} = Oddish.Medicine.create_procedure(scope, attrs)
    procedure
  end

  @doc """
  Generate a visit.
  """
  def visit_fixture(scope, attrs \\ %{}) do
    vet = vet_fixture(scope)
    procedure = procedure_fixture(scope)
    bovine = Oddish.CattleFixtures.bovine_fixture(scope)

    attrs =
      Enum.into(attrs, %{
        bovine_ids: [bovine.id],
        date: ~D[2026-03-20],
        notes: "some notes",
        procedure_id: procedure.id,
        vet_id: vet.id
      })

    {:ok, visit} = Oddish.Medicine.create_visit(scope, attrs)
    visit
  end
end
