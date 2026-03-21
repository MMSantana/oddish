defmodule OddishWeb.ProcedureLiveTest do
  use OddishWeb.ConnCase

  import Phoenix.LiveViewTest
  import Oddish.MedicineFixtures

  @create_attrs %{name: "some name", type: :insemination}
  @update_attrs %{name: "some updated name", type: :touch}
  @invalid_attrs %{name: nil, type: nil}

  setup :register_and_log_in_user_with_org

  defp create_procedure(%{scope: scope}) do
    procedure = procedure_fixture(scope)

    %{procedure: procedure}
  end

  describe "Index" do
    setup [:create_procedure]

    test "lists all procedures", %{conn: conn, procedure: procedure, scope: scope} do
      {:ok, _index_live, html} = live(conn, ~p"/o/#{scope.organization.slug}/procedures")

      assert html =~ "Listing Procedures"
      assert html =~ procedure.name
    end

    test "saves new procedure", %{conn: conn, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/procedures")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Procedure")
               |> render_click()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/procedures/new")

      assert render(form_live) =~ "New Procedure"

      assert form_live
             |> form("#procedure-form", procedure: @invalid_attrs)
             |> render_change() =~ "Não pode estar em branco"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#procedure-form", procedure: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/procedures")

      html = render(index_live)
      assert html =~ "Procedure created successfully"
      assert html =~ "some name"
    end

    test "updates procedure in listing", %{conn: conn, procedure: procedure, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/procedures")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#procedures-#{procedure.id} a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/o/#{scope.organization.slug}/procedures/#{procedure}/edit"
               )

      assert render(form_live) =~ "Edit Procedure"

      assert form_live
             |> form("#procedure-form", procedure: @invalid_attrs)
             |> render_change() =~ "Não pode estar em branco"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#procedure-form", procedure: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/procedures")

      html = render(index_live)
      assert html =~ "Procedure updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes procedure in listing", %{conn: conn, procedure: procedure, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/procedures")

      assert index_live |> element("#procedures-#{procedure.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#procedures-#{procedure.id}")
    end
  end

  describe "Show" do
    setup [:create_procedure]

    test "displays procedure", %{conn: conn, procedure: procedure, scope: scope} do
      {:ok, _show_live, html} =
        live(conn, ~p"/o/#{scope.organization.slug}/procedures/#{procedure}")

      assert html =~ "Show Procedure"
      assert html =~ procedure.name
    end

    test "updates procedure and returns to show", %{
      conn: conn,
      procedure: procedure,
      scope: scope
    } do
      {:ok, show_live, _html} =
        live(conn, ~p"/o/#{scope.organization.slug}/procedures/#{procedure}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/o/#{scope.organization.slug}/procedures/#{procedure}/edit?return_to=show"
               )

      assert render(form_live) =~ "Edit Procedure"

      assert form_live
             |> form("#procedure-form", procedure: @invalid_attrs)
             |> render_change() =~ "Não pode estar em branco"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#procedure-form", procedure: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/procedures/#{procedure}")

      html = render(show_live)
      assert html =~ "Procedure updated successfully"
      assert html =~ "some updated name"
    end
  end
end
