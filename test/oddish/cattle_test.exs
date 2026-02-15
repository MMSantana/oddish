defmodule Oddish.CattleTest do
  use Oddish.DataCase

  alias Oddish.Cattle

  describe "bovines" do
    alias Oddish.Cattle.Bovine
    alias Oddish.Cattle.BovinePackHistory

    import Oddish.AccountsFixtures, only: [organization_scope_fixture: 0]
    import Oddish.CattleFixtures
    import Oddish.PacksFixtures

    @invalid_attrs %{
      name: nil,
      description: nil,
      registration_number: nil,
      gender: nil,
      mother_id: nil,
      date_of_birth: nil,
      observation: nil
    }

    test "list_bovines/1 returns all scoped bovines" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      bovine = bovine_fixture(scope)
      other_bovine = bovine_fixture(other_scope)
      assert Cattle.list_bovines(scope) == [bovine]
      assert Cattle.list_bovines(other_scope) == [other_bovine]

      bovine_pack_history = BovinePackHistory.get_active(scope, bovine)

      assert bovine_pack_history.bovine_id == bovine.id
      assert bovine_pack_history.pack_id == bovine.pack_id
    end

    test "get_bovine!/2 returns the bovine with given id" do
      scope = organization_scope_fixture()
      bovine = bovine_fixture(scope)
      other_scope = organization_scope_fixture()
      assert Cattle.get_bovine!(scope, bovine.id) == bovine
      assert_raise Ecto.NoResultsError, fn -> Cattle.get_bovine!(other_scope, bovine.id) end
    end

    test "create_bovine/2 with valid data creates a bovine" do
      valid_attrs = %{
        name: "some name",
        description: "some description",
        registration_number: "some registration_number",
        gender: :male,
        date_of_birth: ~D[2026-02-04],
        observation: "some observation",
        status: :active
      }

      scope = organization_scope_fixture()

      assert {:ok, %Bovine{} = bovine} = Cattle.create_bovine(scope, valid_attrs)
      assert bovine.name == "some name"
      assert bovine.description == "some description"
      assert bovine.registration_number == "some registration_number"
      assert bovine.gender == :male
      assert bovine.date_of_birth == ~D[2026-02-04]
      assert bovine.observation == "some observation"
      assert bovine.org_id == scope.organization.id
    end

    test "create_bovine/2 with invalid data returns error changeset" do
      scope = organization_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Cattle.create_bovine(scope, @invalid_attrs)
    end

    test "update_bovine/3 with valid data updates the bovine" do
      scope = organization_scope_fixture()
      bovine = bovine_fixture(scope)
      other_pack = pack_fixture(scope)
      bovine_pack_history = BovinePackHistory.get_active(scope, bovine)

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        registration_number: "some updated registration_number",
        gender: :female,
        date_of_birth: ~D[2026-02-05],
        observation: "some updated observation",
        pack_id: other_pack.id
      }

      assert {:ok, %Bovine{} = bovine} = Cattle.update_bovine(scope, bovine, update_attrs)
      assert bovine.name == "some updated name"
      assert bovine.description == "some updated description"
      assert bovine.registration_number == "some updated registration_number"
      assert bovine.gender == :female
      assert bovine.mother_id == nil
      assert bovine.date_of_birth == ~D[2026-02-05]
      assert bovine.observation == "some updated observation"
      assert bovine.pack_id == other_pack.id

      finished_bovine_pack_history = BovinePackHistory.get!(scope, bovine_pack_history.id)
      new_bovine_pack_history = BovinePackHistory.get_active(scope, bovine)

      assert %BovinePackHistory{} = finished_bovine_pack_history
      assert %BovinePackHistory{} = new_bovine_pack_history
      assert finished_bovine_pack_history.end_date != nil
      assert new_bovine_pack_history.end_date == nil
    end

    test "update_bovine/3 with invalid scope raises" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      bovine = bovine_fixture(scope)

      assert_raise MatchError, fn ->
        Cattle.update_bovine(other_scope, bovine, %{})
      end
    end

    test "update_bovine/3 with invalid data returns error changeset" do
      scope = organization_scope_fixture()
      bovine = bovine_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Cattle.update_bovine(scope, bovine, @invalid_attrs)
      assert bovine == Cattle.get_bovine!(scope, bovine.id)
    end

    test "delete_bovine/2 deletes the bovine" do
      scope = organization_scope_fixture()
      bovine = bovine_fixture(scope)
      assert {:ok, %Bovine{}} = Cattle.delete_bovine(scope, bovine)
      assert_raise Ecto.NoResultsError, fn -> Cattle.get_bovine!(scope, bovine.id) end
    end

    test "delete_bovine/2 with invalid scope raises" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      bovine = bovine_fixture(scope)
      assert_raise MatchError, fn -> Cattle.delete_bovine(other_scope, bovine) end
    end

    test "change_bovine/2 returns a bovine changeset" do
      scope = organization_scope_fixture()
      bovine = bovine_fixture(scope)
      assert %Ecto.Changeset{} = Cattle.change_bovine(scope, bovine)
    end
  end
end
