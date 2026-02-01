defmodule Oddish.SoltasTest do
  use Oddish.DataCase

  alias Oddish.Soltas

  describe "soltas" do
    alias Oddish.Soltas.Solta

    import Oddish.AccountsFixtures, only: [organization_scope_fixture: 0]
    import Oddish.SoltasFixtures

    @invalid_attrs %{name: nil, area: nil, grass_type: nil}

    test "list_soltas/1 returns all scoped soltas" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      solta = solta_fixture(scope)
      other_solta = solta_fixture(other_scope)
      assert Soltas.list_soltas(scope) == [solta]
      assert Soltas.list_soltas(other_scope) == [other_solta]
    end

    test "get_solta!/2 returns the solta with given id" do
      scope = organization_scope_fixture()
      solta = solta_fixture(scope)
      other_scope = organization_scope_fixture()
      assert Soltas.get_solta!(scope, solta.id) == solta
      assert_raise Ecto.NoResultsError, fn -> Soltas.get_solta!(other_scope, solta.id) end
    end

    test "create_solta/2 with valid data creates a solta" do
      valid_attrs = %{name: "some name", area: "120.5", grass_type: "some grass_type"}
      scope = organization_scope_fixture()

      assert {:ok, %Solta{} = solta} = Soltas.create_solta(scope, valid_attrs)
      assert solta.name == "some name"
      assert solta.area == Decimal.new("120.5")
      assert solta.grass_type == "some grass_type"
      assert solta.org_id == scope.organization.id
    end

    test "create_solta/2 with invalid data returns error changeset" do
      scope = organization_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Soltas.create_solta(scope, @invalid_attrs)
    end

    test "update_solta/3 with valid data updates the solta" do
      scope = organization_scope_fixture()
      solta = solta_fixture(scope)

      update_attrs = %{
        name: "some updated name",
        area: "456.7",
        grass_type: "some updated grass_type"
      }

      assert {:ok, %Solta{} = solta} = Soltas.update_solta(scope, solta, update_attrs)
      assert solta.name == "some updated name"
      assert solta.area == Decimal.new("456.7")
      assert solta.grass_type == "some updated grass_type"
    end

    test "update_solta/3 with invalid scope raises" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      solta = solta_fixture(scope)

      assert_raise MatchError, fn ->
        Soltas.update_solta(other_scope, solta, %{})
      end
    end

    test "update_solta/3 with invalid data returns error changeset" do
      scope = organization_scope_fixture()
      solta = solta_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Soltas.update_solta(scope, solta, @invalid_attrs)
      assert solta == Soltas.get_solta!(scope, solta.id)
    end

    test "delete_solta/2 deletes the solta" do
      scope = organization_scope_fixture()
      solta = solta_fixture(scope)
      assert {:ok, %Solta{}} = Soltas.delete_solta(scope, solta)
      assert_raise Ecto.NoResultsError, fn -> Soltas.get_solta!(scope, solta.id) end
    end

    test "delete_solta/2 with invalid scope raises" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      solta = solta_fixture(scope)
      assert_raise MatchError, fn -> Soltas.delete_solta(other_scope, solta) end
    end

    test "change_solta/2 returns a solta changeset" do
      scope = organization_scope_fixture()
      solta = solta_fixture(scope)
      assert %Ecto.Changeset{} = Soltas.change_solta(scope, solta)
    end
  end
end
