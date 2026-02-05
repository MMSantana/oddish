defmodule Oddish.PacksTest do
  use Oddish.DataCase

  alias Oddish.Packs

  describe "packs" do
    alias Oddish.Packs.Pack

    import Oddish.AccountsFixtures, only: [organization_scope_fixture: 0]
    import Oddish.PacksFixtures

    @invalid_attrs %{name: nil, status: nil, flock_type: nil, animal_count: nil}

    test "list_packs/1 returns all scoped packs" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      pack = pack_fixture(scope)
      other_pack = pack_fixture(other_scope)
      assert Packs.list_packs(scope) == [pack]
      assert Packs.list_packs(other_scope) == [other_pack]
    end

    test "get_pack!/2 returns the pack with given id" do
      scope = organization_scope_fixture()
      pack = pack_fixture(scope)
      other_scope = organization_scope_fixture()
      assert Packs.get_pack!(scope, pack.id) == pack
      assert_raise Ecto.NoResultsError, fn -> Packs.get_pack!(other_scope, pack.id) end
    end

    test "create_pack/2 with valid data creates a pack" do
      valid_attrs = %{name: "some name", status: :active, flock_type: :bezerros, animal_count: 42}
      scope = organization_scope_fixture()

      assert {:ok, %Pack{} = pack} = Packs.create_pack(scope, valid_attrs)
      assert pack.name == "some name"
      assert pack.status == :active
      assert pack.flock_type == :bezerros
      assert pack.animal_count == 42
      assert pack.org_id == scope.organization.id
    end

    test "create_pack/2 with invalid data returns error changeset" do
      scope = organization_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Packs.create_pack(scope, @invalid_attrs)
    end

    test "update_pack/3 with valid data updates the pack" do
      scope = organization_scope_fixture()
      pack = pack_fixture(scope)

      update_attrs = %{
        name: "some updated name",
        status: :inactive,
        flock_type: :bois,
        animal_count: 43
      }

      assert {:ok, %Pack{} = pack} = Packs.update_pack(scope, pack, update_attrs)
      assert pack.name == "some updated name"
      assert pack.status == :inactive
      assert pack.flock_type == :bois
      assert pack.animal_count == 43
    end

    test "update_pack/3 with invalid scope raises" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      pack = pack_fixture(scope)

      assert_raise MatchError, fn ->
        Packs.update_pack(other_scope, pack, %{})
      end
    end

    test "update_pack/3 with invalid data returns error changeset" do
      scope = organization_scope_fixture()
      pack = pack_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Packs.update_pack(scope, pack, @invalid_attrs)
      assert pack == Packs.get_pack!(scope, pack.id)
    end

    test "delete_pack/2 deletes the pack" do
      scope = organization_scope_fixture()
      pack = pack_fixture(scope)
      assert {:ok, %Pack{}} = Packs.delete_pack(scope, pack)
      assert_raise Ecto.NoResultsError, fn -> Packs.get_pack!(scope, pack.id) end
    end

    test "delete_pack/2 with invalid scope raises" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      pack = pack_fixture(scope)
      assert_raise MatchError, fn -> Packs.delete_pack(other_scope, pack) end
    end

    test "change_pack/2 returns a pack changeset" do
      scope = organization_scope_fixture()
      pack = pack_fixture(scope)
      assert %Ecto.Changeset{} = Packs.change_pack(scope, pack)
    end
  end
end
