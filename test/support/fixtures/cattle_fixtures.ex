defmodule Oddish.CattleFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Oddish.Cattle` context.
  """

  @doc """
  Generate a bovine.
  """
  def bovine_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        date_of_birth: ~D[2026-02-04],
        description: "some description",
        gender: :male,
        mother_id: nil,
        name: "some name",
        observation: "some observation",
        registration_number: "some registration_number",
        status: :active
      })

    {:ok, bovine} = Oddish.Cattle.create_bovine(scope, attrs)
    bovine
  end
end
