defmodule Oddish.GrazesTest do
  use Oddish.DataCase

  alias Oddish.Grazes

  describe "grazes" do
    alias Oddish.Grazes.Graze

    import Oddish.AccountsFixtures, only: [organization_scope_fixture: 0]
    import Oddish.GrazesFixtures

    @invalid_attrs %{
      status: nil,
      pack_id: nil,
      start_date: nil,
      end_date: nil,
      planned_period: nil,
      solta_id: nil
    }

    test "list_grazes/1 returns all scoped grazes" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      graze = graze_fixture(scope)
      other_graze = graze_fixture(other_scope)
      assert Grazes.list_grazes(scope) == [Repo.preload(graze, :solta)]
      assert Grazes.list_grazes(other_scope) == [Repo.preload(other_graze, :solta)]
    end

    test "get_graze!/2 returns the graze with given id" do
      scope = organization_scope_fixture()
      graze = graze_fixture(scope)
      other_scope = organization_scope_fixture()
      assert Grazes.get_graze!(scope, graze.id) == Repo.preload(graze, :solta)
      assert_raise Ecto.NoResultsError, fn -> Grazes.get_graze!(other_scope, graze.id) end
    end

    test "create_graze/2 with valid data creates a graze" do
      scope = organization_scope_fixture()
      solta = Oddish.SoltasFixtures.solta_fixture(scope)
      pack = Oddish.PacksFixtures.pack_fixture(scope)

      valid_attrs = %{
        status: "planned",
        start_date: ~D[2026-01-31],
        end_date: nil,
        planned_period: 42,
        solta_id: solta.id,
        pack_id: pack.id
      }

      assert {:ok, %Graze{} = graze} = Grazes.create_graze(scope, valid_attrs)
      assert graze.status == :planned
      assert graze.start_date == ~D[2026-01-31]
      assert graze.end_date == nil
      assert graze.planned_period == 42
      assert graze.solta_id == solta.id
      assert graze.org_id == scope.organization.id
    end

    test "create_graze/2 with invalid data returns error changeset" do
      scope = organization_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Grazes.create_graze(scope, @invalid_attrs)
    end

    test "update_graze/3 with valid data updates the graze" do
      scope = organization_scope_fixture()
      graze = graze_fixture(scope)
      other_solta = Oddish.SoltasFixtures.solta_fixture(scope)
      other_pack = Oddish.PacksFixtures.pack_fixture(scope)

      update_attrs = %{
        status: "finished",
        start_date: ~D[2026-02-01],
        end_date: ~D[2026-02-01],
        planned_period: 43,
        solta_id: other_solta.id,
        pack_id: other_pack.id
      }

      assert {:ok, %Graze{} = graze} = Grazes.update_graze(scope, graze, update_attrs)
      assert graze.status == :finished
      assert graze.start_date == ~D[2026-02-01]
      assert graze.end_date == ~D[2026-02-01]
      assert graze.planned_period == 43
      assert graze.solta_id == other_solta.id
      assert graze.pack_id == other_pack.id
    end

    test "update_graze/3 with invalid scope raises" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      graze = graze_fixture(scope)

      assert_raise MatchError, fn ->
        Grazes.update_graze(other_scope, graze, %{})
      end
    end

    test "update_graze/3 with invalid data returns error changeset" do
      scope = organization_scope_fixture()
      graze = graze_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Grazes.update_graze(scope, graze, @invalid_attrs)
      assert Repo.preload(graze, :solta) == Grazes.get_graze!(scope, graze.id)
    end

    test "delete_graze/2 deletes the graze" do
      scope = organization_scope_fixture()
      graze = graze_fixture(scope)
      assert {:ok, %Graze{}} = Grazes.delete_graze(scope, graze)
      assert_raise Ecto.NoResultsError, fn -> Grazes.get_graze!(scope, graze.id) end
    end

    test "delete_graze/2 with invalid scope raises" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      graze = graze_fixture(scope)
      assert_raise MatchError, fn -> Grazes.delete_graze(other_scope, graze) end
    end

    test "change_graze/2 returns a graze changeset" do
      scope = organization_scope_fixture()
      graze = graze_fixture(scope)
      assert %Ecto.Changeset{} = Grazes.change_graze(scope, graze)
    end
  end
end
