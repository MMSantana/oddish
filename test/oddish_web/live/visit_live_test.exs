defmodule OddishWeb.VisitLiveTest do
  use OddishWeb.ConnCase

  import Phoenix.LiveViewTest
  import Oddish.MedicineFixtures

  @invalid_attrs %{date: nil, vet_id: nil, procedure_id: nil, notes: nil}

  setup :register_and_log_in_user_with_org

  defp create_visit(%{scope: scope}) do
    visit = visit_fixture(scope)

    %{visit: visit}
  end

  describe "Index" do
    setup [:create_visit]

    test "lists all visits", %{conn: conn, visit: _visit, scope: scope} do
      {:ok, _index_live, html} = live(conn, ~p"/o/#{scope.organization.slug}/visits")

      assert html =~ "Listando Visitas"
    end

    test "saves new visit", %{conn: conn, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/visits")
      vet = Oddish.MedicineFixtures.vet_fixture(scope)
      procedure = Oddish.MedicineFixtures.procedure_fixture(scope)
      bovine = Oddish.CattleFixtures.bovine_fixture(scope)

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "Nova Visita")
               |> render_click()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/visits/new")

      assert render(form_live) =~ "Nova Visita"

      assert form_live
             |> form("#visit-form", visit: @invalid_attrs)
             |> render_change() =~ "Não pode estar em branco"

      form_live
      |> element("input[phx-keyup=\"search_bovine\"]")
      |> render_keyup(%{"value" => bovine.name})

      form_live
      |> element("li[phx-value-id=\"#{bovine.id}\"]")
      |> render_click()

      assert {:ok, index_live, _html} =
               form_live
               |> form("#visit-form",
                 visit: %{
                   date: "2026-03-20",
                   vet_id: vet.id,
                   procedure_id: procedure.id,
                   bovine_ids: [to_string(bovine.id)],
                   notes: "some notes"
                 }
               )
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/visits")

      html = render(index_live)
      assert html =~ "Visita criada com sucesso"
    end

    test "updates visit in listing", %{conn: conn, visit: visit, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/visits")
      vet = Oddish.MedicineFixtures.vet_fixture(scope)
      procedure = Oddish.MedicineFixtures.procedure_fixture(scope)
      bovine = Oddish.CattleFixtures.bovine_fixture(scope)

      assert {:ok, form_live, _html} =
               index_live
               |> element("#visits-#{visit.id} a", "Editar")
               |> render_click()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/visits/#{visit}/edit")

      assert render(form_live) =~ "Editar Visita"

      assert form_live
             |> form("#visit-form", visit: @invalid_attrs)
             |> render_change() =~ "Não pode estar em branco"

      form_live
      |> element("input[phx-keyup=\"search_bovine\"]")
      |> render_keyup(%{"value" => bovine.name})

      form_live
      |> element("li[phx-value-id=\"#{bovine.id}\"]")
      |> render_click()

      assert {:ok, index_live, _html} =
               form_live
               |> form("#visit-form",
                 visit: %{
                   date: "2026-03-21",
                   vet_id: vet.id,
                   procedure_id: procedure.id,
                   bovine_ids: [to_string(bovine.id)],
                   notes: "some updated notes"
                 }
               )
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/visits")

      html = render(index_live)
      assert html =~ "Visita atualizada com sucesso"
    end

    test "deletes visit in listing", %{conn: conn, visit: visit, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/visits")

      assert index_live |> element("#visits-#{visit.id} a", "Excluir") |> render_click()
      refute has_element?(index_live, "#visits-#{visit.id}")
    end
  end

  describe "Show" do
    setup [:create_visit]

    test "displays visit", %{conn: conn, visit: visit, scope: scope} do
      {:ok, _show_live, html} = live(conn, ~p"/o/#{scope.organization.slug}/visits/#{visit}")

      assert html =~ "Ver Visita"
    end

    test "updates visit and returns to show", %{conn: conn, visit: visit, scope: scope} do
      {:ok, show_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/visits/#{visit}")
      vet = Oddish.MedicineFixtures.vet_fixture(scope)
      procedure = Oddish.MedicineFixtures.procedure_fixture(scope)
      bovine = Oddish.CattleFixtures.bovine_fixture(scope)

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Editar")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/o/#{scope.organization.slug}/visits/#{visit}/edit?return_to=show"
               )

      assert render(form_live) =~ "Editar Visita"

      assert form_live
             |> form("#visit-form", visit: @invalid_attrs)
             |> render_change() =~ "Não pode estar em branco"

      form_live
      |> element("input[phx-keyup=\"search_bovine\"]")
      |> render_keyup(%{"value" => bovine.name})

      form_live
      |> element("li[phx-value-id=\"#{bovine.id}\"]")
      |> render_click()

      assert {:ok, show_live, _html} =
               form_live
               |> form("#visit-form",
                 visit: %{
                   date: "2026-03-21",
                   vet_id: vet.id,
                   procedure_id: procedure.id,
                   bovine_ids: [to_string(bovine.id)],
                   notes: "some updated notes"
                 }
               )
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/visits/#{visit}")

      html = render(show_live)
      assert html =~ "Visita atualizada com sucesso"
    end
  end
end
