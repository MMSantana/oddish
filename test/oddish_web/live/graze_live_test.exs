defmodule OddishWeb.GrazeLiveTest do
  use OddishWeb.ConnCase

  import Phoenix.LiveViewTest
  import Oddish.GrazesFixtures

  @update_attrs %{
    status: :ongoing,
    start_date: "2026-02-01",
    end_date: "2026-02-01",
    planned_period: 43
  }
  @invalid_attrs %{
    status: nil,
    start_date: nil,
    end_date: nil,
    planned_period: nil,
    solta_id: nil
  }

  setup :register_and_log_in_user_with_org

  defp create_graze(%{scope: scope}) do
    graze = graze_fixture(scope)

    %{graze: Oddish.Repo.preload(graze, [:pack])}
  end

  describe "Index" do
    setup [:create_graze]

    test "lists all grazes", %{conn: conn, scope: scope} do
      {:ok, _index_live, html} = live(conn, ~p"/o/#{scope.organization.slug}/grazes")

      assert html =~ "Lista de manejos"
    end

    test "saves new graze", %{conn: conn, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/grazes")
      solta = Oddish.SoltasFixtures.solta_fixture(scope)
      pack = Oddish.PacksFixtures.pack_fixture(scope)

      create_attrs = %{
        status: "planned",
        start_date: "2026-01-31",
        end_date: "2026-01-31",
        planned_period: 42,
        pack_id: pack.id,
        solta_id: solta.id
      }

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "Novo manejo")
               |> render_click()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/grazes/new")

      assert render(form_live) =~ "Novo manejo"

      assert form_live
             |> form("#graze-form", graze: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#graze-form", graze: create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/grazes")

      html = render(index_live)
      assert html =~ "Manejo criado"
    end

    test "updates graze in listing", %{conn: conn, graze: graze, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/grazes/history")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#grazes-#{graze.id} a", "Editar")
               |> render_click()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/grazes/#{graze}/edit")

      assert render(form_live) =~ "Editar manejo"

      assert form_live
             |> form("#graze-form", graze: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#graze-form", graze: Map.put(@update_attrs, :solta_id, graze.solta_id))
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/grazes")

      html = render(index_live)
      assert html =~ "Manejo atualizado"
    end

    test "deletes graze in listing", %{conn: conn, graze: graze, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/grazes/history")

      assert index_live |> element("#grazes-#{graze.id} a", "Deletar") |> render_click()
      refute has_element?(index_live, "#grazes-#{graze.id}")
    end
  end

  describe "Show" do
    setup [:create_graze]

    test "displays graze", %{conn: conn, graze: graze, scope: scope} do
      {:ok, _show_live, html} = live(conn, ~p"/o/#{scope.organization.slug}/grazes/#{graze}")

      assert html =~ "Manejo"
      assert html =~ String.capitalize(Atom.to_string(graze.pack.flock_type))
    end

    test "updates graze and returns to show", %{conn: conn, graze: graze, scope: scope} do
      {:ok, show_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/grazes/#{graze}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Editar manejo")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/o/#{scope.organization.slug}/grazes/#{graze}/edit?return_to=show"
               )

      assert render(form_live) =~ "Editar manejo"

      assert form_live
             |> form("#graze-form", graze: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#graze-form", graze: Map.put(@update_attrs, :solta_id, graze.solta_id))
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/grazes/#{graze}")

      html = render(show_live)
      assert html =~ "Manejo atualizado"
      assert html =~ "Bezerros"
    end
  end
end
