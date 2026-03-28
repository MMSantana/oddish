defmodule Oddish.MedicineTest do
  use Oddish.DataCase

  alias Oddish.Medicine

  describe "vets" do
    alias Oddish.Medicine.Vet

    import Oddish.AccountsFixtures, only: [organization_scope_fixture: 0]
    import Oddish.MedicineFixtures

    @invalid_attrs %{name: nil, telephone: nil, email: nil}

    test "list_vets/1 returns all scoped vets" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      vet = vet_fixture(scope)
      other_vet = vet_fixture(other_scope)
      assert Medicine.list_vets(scope) == [vet]
      assert Medicine.list_vets(other_scope) == [other_vet]
    end

    test "get_vet!/2 returns the vet with given id" do
      scope = organization_scope_fixture()
      vet = vet_fixture(scope)
      other_scope = organization_scope_fixture()
      assert Medicine.get_vet!(scope, vet.id) == vet
      assert_raise Ecto.NoResultsError, fn -> Medicine.get_vet!(other_scope, vet.id) end
    end

    test "create_vet/2 with valid data creates a vet" do
      valid_attrs = %{name: "some name", telephone: "some telephone", email: "some email"}
      scope = organization_scope_fixture()

      assert {:ok, %Vet{} = vet} = Medicine.create_vet(scope, valid_attrs)
      assert vet.name == "some name"
      assert vet.telephone == "some telephone"
      assert vet.email == "some email"
      assert vet.org_id == scope.organization.id
    end

    test "create_vet/2 with invalid data returns error changeset" do
      scope = organization_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Medicine.create_vet(scope, @invalid_attrs)
    end

    test "update_vet/3 with valid data updates the vet" do
      scope = organization_scope_fixture()
      vet = vet_fixture(scope)

      update_attrs = %{
        name: "some updated name",
        telephone: "some updated telephone",
        email: "some updated email"
      }

      assert {:ok, %Vet{} = vet} = Medicine.update_vet(scope, vet, update_attrs)
      assert vet.name == "some updated name"
      assert vet.telephone == "some updated telephone"
      assert vet.email == "some updated email"
    end

    test "update_vet/3 with invalid scope raises" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      vet = vet_fixture(scope)

      assert_raise MatchError, fn ->
        Medicine.update_vet(other_scope, vet, %{})
      end
    end

    test "update_vet/3 with invalid data returns error changeset" do
      scope = organization_scope_fixture()
      vet = vet_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Medicine.update_vet(scope, vet, @invalid_attrs)
      assert vet == Medicine.get_vet!(scope, vet.id)
    end

    test "delete_vet/2 deletes the vet" do
      scope = organization_scope_fixture()
      vet = vet_fixture(scope)
      assert {:ok, %Vet{}} = Medicine.delete_vet(scope, vet)
      assert_raise Ecto.NoResultsError, fn -> Medicine.get_vet!(scope, vet.id) end
    end

    test "delete_vet/2 with invalid scope raises" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      vet = vet_fixture(scope)
      assert_raise MatchError, fn -> Medicine.delete_vet(other_scope, vet) end
    end

    test "change_vet/2 returns a vet changeset" do
      scope = organization_scope_fixture()
      vet = vet_fixture(scope)
      assert %Ecto.Changeset{} = Medicine.change_vet(scope, vet)
    end
  end

  describe "procedures" do
    alias Oddish.Medicine.Procedure

    import Oddish.AccountsFixtures, only: [organization_scope_fixture: 0]
    import Oddish.MedicineFixtures

    @invalid_attrs %{name: nil, kind: nil}

    test "list_procedures/1 returns all scoped procedures" do
      scope = organization_scope_fixture()
      default_procedures = Medicine.list_procedures(scope)

      other_scope = organization_scope_fixture()
      other_default_procedures = Medicine.list_procedures(other_scope)

      procedure = procedure_fixture(scope)
      other_procedure = procedure_fixture(other_scope)

      assert Medicine.list_procedures(scope) == default_procedures ++ [procedure]

      assert Medicine.list_procedures(other_scope) ==
               other_default_procedures ++ [other_procedure]
    end

    test "get_procedure!/2 returns the procedure with given id" do
      scope = organization_scope_fixture()
      procedure = procedure_fixture(scope)
      other_scope = organization_scope_fixture()
      assert Medicine.get_procedure!(scope, procedure.id) == procedure

      assert_raise Ecto.NoResultsError, fn ->
        Medicine.get_procedure!(other_scope, procedure.id)
      end
    end

    test "create_procedure/2 with valid data creates a procedure" do
      valid_attrs = %{name: "some name", kind: :iatf}
      scope = organization_scope_fixture()

      assert {:ok, %Procedure{} = procedure} = Medicine.create_procedure(scope, valid_attrs)
      assert procedure.name == "some name"
      assert procedure.kind == :iatf
      assert procedure.org_id == scope.organization.id
    end

    test "create_procedure/2 with invalid data returns error changeset" do
      scope = organization_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Medicine.create_procedure(scope, @invalid_attrs)
    end

    test "update_procedure/3 with valid data updates the procedure" do
      scope = organization_scope_fixture()
      procedure = procedure_fixture(scope)
      update_attrs = %{name: "some updated name", kind: :vaccine}

      assert {:ok, %Procedure{} = procedure} =
               Medicine.update_procedure(scope, procedure, update_attrs)

      assert procedure.name == "some updated name"
      assert procedure.kind == :vaccine
    end

    test "update_procedure/3 with invalid scope raises" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      procedure = procedure_fixture(scope)

      assert_raise MatchError, fn ->
        Medicine.update_procedure(other_scope, procedure, %{})
      end
    end

    test "update_procedure/3 with invalid data returns error changeset" do
      scope = organization_scope_fixture()
      procedure = procedure_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Medicine.update_procedure(scope, procedure, @invalid_attrs)

      assert procedure == Medicine.get_procedure!(scope, procedure.id)
    end

    test "delete_procedure/2 deletes the procedure" do
      scope = organization_scope_fixture()
      procedure = procedure_fixture(scope)
      assert {:ok, %Procedure{}} = Medicine.delete_procedure(scope, procedure)
      assert_raise Ecto.NoResultsError, fn -> Medicine.get_procedure!(scope, procedure.id) end
    end

    test "delete_procedure/2 with invalid scope raises" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      procedure = procedure_fixture(scope)
      assert_raise MatchError, fn -> Medicine.delete_procedure(other_scope, procedure) end
    end

    test "change_procedure/2 returns a procedure changeset" do
      scope = organization_scope_fixture()
      procedure = procedure_fixture(scope)
      assert %Ecto.Changeset{} = Medicine.change_procedure(scope, procedure)
    end
  end

  describe "visits" do
    alias Oddish.Medicine.Visit

    import Oddish.AccountsFixtures, only: [organization_scope_fixture: 0]
    import Oddish.MedicineFixtures

    @invalid_attrs %{date: nil, vet: nil, procedure: nil, bovine: nil, notes: nil}

    test "list_visits/1 returns all scoped visits" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      visit = visit_fixture(scope)
      other_visit = visit_fixture(other_scope)
      assert Medicine.list_visits(scope) == [visit]
      assert Medicine.list_visits(other_scope) == [other_visit]
    end

    test "get_visit!/2 returns the visit with given id" do
      scope = organization_scope_fixture()
      visit = visit_fixture(scope)
      other_scope = organization_scope_fixture()
      assert Medicine.get_visit!(scope, visit.id) == visit
      assert_raise Ecto.NoResultsError, fn -> Medicine.get_visit!(other_scope, visit.id) end
    end

    test "create_visit/2 with valid data creates a visit" do
      scope = organization_scope_fixture()
      bovine = Oddish.CattleFixtures.bovine_fixture(scope)
      vet = Oddish.MedicineFixtures.vet_fixture(scope)
      procedure = Oddish.MedicineFixtures.procedure_fixture(scope)

      valid_attrs = %{
        date: ~D[2026-03-20],
        vet_id: vet.id,
        procedure_id: procedure.id,
        bovine_ids: [bovine.id],
        notes: "some notes"
      }

      assert {:ok, %Visit{} = visit} = Medicine.create_visit(scope, valid_attrs)
      assert visit.date == ~D[2026-03-20]
      assert visit.vet_id == vet.id
      assert visit.procedure_id == procedure.id
      assert Enum.map(visit.bovines, & &1.id) == [bovine.id]
      assert visit.notes == "some notes"
      assert visit.org_id == scope.organization.id
    end

    test "create_visit/2 with invalid data returns error changeset" do
      scope = organization_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Medicine.create_visit(scope, @invalid_attrs)
    end

    test "update_visit/3 with valid data updates the visit" do
      scope = organization_scope_fixture()
      visit = visit_fixture(scope)
      bovine = Oddish.CattleFixtures.bovine_fixture(scope)
      vet = Oddish.MedicineFixtures.vet_fixture(scope)
      procedure = Oddish.MedicineFixtures.procedure_fixture(scope)

      update_attrs = %{
        date: ~D[2026-03-21],
        vet_id: vet.id,
        procedure_id: procedure.id,
        bovine_ids: [bovine.id],
        notes: "some updated notes"
      }

      assert {:ok, %Visit{} = visit} = Medicine.update_visit(scope, visit, update_attrs)
      assert visit.date == ~D[2026-03-21]
      assert visit.vet_id == vet.id
      assert visit.procedure_id == procedure.id
      assert Enum.map(visit.bovines, & &1.id) == [bovine.id]
      assert visit.notes == "some updated notes"
    end

    test "update_visit/3 with invalid scope raises" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      visit = visit_fixture(scope)

      assert_raise MatchError, fn ->
        Medicine.update_visit(other_scope, visit, %{})
      end
    end

    test "update_visit/3 with invalid data returns error changeset" do
      scope = organization_scope_fixture()
      visit = visit_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Medicine.update_visit(scope, visit, @invalid_attrs)
      assert visit == Medicine.get_visit!(scope, visit.id)
    end

    test "delete_visit/2 deletes the visit" do
      scope = organization_scope_fixture()
      visit = visit_fixture(scope)
      assert {:ok, %Visit{}} = Medicine.delete_visit(scope, visit)
      assert_raise Ecto.NoResultsError, fn -> Medicine.get_visit!(scope, visit.id) end
    end

    test "delete_visit/2 with invalid scope raises" do
      scope = organization_scope_fixture()
      other_scope = organization_scope_fixture()
      visit = visit_fixture(scope)
      assert_raise MatchError, fn -> Medicine.delete_visit(other_scope, visit) end
    end

    test "change_visit/2 returns a visit changeset" do
      scope = organization_scope_fixture()
      visit = visit_fixture(scope)
      assert %Ecto.Changeset{} = Medicine.change_visit(scope, visit)
    end
  end
end
