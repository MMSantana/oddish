defmodule OddishWeb.SoltaLiveTest do
  use OddishWeb.ConnCase

  import Phoenix.LiveViewTest
  import Oddish.SoltasFixtures

  @create_attrs %{name: "some name", area: "120.5", grass_type: "some grass_type"}
  @update_attrs %{name: "some updated name", area: "456.7", grass_type: "some updated grass_type"}
  @invalid_attrs %{name: nil, area: nil, grass_type: nil}

  setup :register_and_log_in_user_with_org

  defp create_solta(%{scope: scope}) do
    solta = solta_fixture(scope)

    %{solta: solta}
  end

  describe "Index" do
    setup [:create_solta]

    test "lists all soltas", %{conn: conn, solta: solta, scope: scope} do
      {:ok, _index_live, html} = live(conn, ~p"/o/#{scope.organization.slug}/soltas")

      assert html =~ "Listing Soltas"
      assert html =~ solta.name
    end

    test "saves new solta", %{conn: conn, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/soltas")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Solta")
               |> render_click()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/soltas/new")

      assert render(form_live) =~ "New Solta"

      assert form_live
             |> form("#solta-form", solta: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#solta-form", solta: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/soltas")

      html = render(index_live)
      assert html =~ "Solta created successfully"
      assert html =~ "some name"
    end

    test "updates solta in listing", %{conn: conn, solta: solta, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/soltas")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#soltas-#{solta.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/soltas/#{solta}/edit")

      assert render(form_live) =~ "Edit Solta"

      assert form_live
             |> form("#solta-form", solta: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#solta-form", solta: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/soltas")

      html = render(index_live)
      assert html =~ "Solta updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes solta in listing", %{conn: conn, solta: solta, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/soltas")

      assert index_live |> element("#soltas-#{solta.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#soltas-#{solta.id}")
    end
  end

  describe "Show" do
    setup [:create_solta]

    test "displays solta", %{conn: conn, solta: solta, scope: scope} do
      {:ok, _show_live, html} = live(conn, ~p"/o/#{scope.organization.slug}/soltas/#{solta}")

      assert html =~ "Show Solta"
      assert html =~ solta.name
    end

    test "updates solta and returns to show", %{conn: conn, solta: solta, scope: scope} do
      {:ok, show_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/soltas/#{solta}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/o/#{scope.organization.slug}/soltas/#{solta}/edit?return_to=show"
               )

      assert render(form_live) =~ "Edit Solta"

      assert form_live
             |> form("#solta-form", solta: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#solta-form", solta: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/soltas/#{solta}")

      html = render(show_live)
      assert html =~ "Solta updated successfully"
      assert html =~ "some updated name"
    end
  end
end
