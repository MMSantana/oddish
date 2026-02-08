defmodule OddishWeb.BovineLiveTest do
  use OddishWeb.ConnCase

  import Phoenix.LiveViewTest
  import Oddish.CattleFixtures

  @create_attrs %{
    name: "some name",
    description: "some description",
    registration_number: "some registration_number",
    gender: :male,
    date_of_birth: ~D[2026-02-04],
    observation: "some observation",
    status: :active
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    registration_number: "some updated registration_number",
    gender: :female,
    date_of_birth: ~D[2026-02-05],
    observation: "some updated observation"
  }
  @invalid_attrs %{
    name: nil,
    description: nil,
    registration_number: nil,
    gender: nil,
    date_of_birth: nil,
    observation: nil
  }

  setup :register_and_log_in_user_with_org

  defp create_bovine(%{scope: scope}) do
    bovine = bovine_fixture(scope)

    %{bovine: bovine}
  end

  describe "Index" do
    setup [:create_bovine]

    test "lists all bovines", %{conn: conn, bovine: bovine, scope: scope} do
      {:ok, _index_live, html} = live(conn, ~p"/o/#{scope.organization.slug}/bovines")

      assert html =~ "Animais"
      assert html =~ bovine.name
    end

    test "saves new bovine", %{conn: conn, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/bovines")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "Novo")
               |> render_click()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/bovines/new")

      assert render(form_live) =~ "Novo"

      assert form_live
             |> form("#bovine-form", bovine: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#bovine-form", bovine: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/bovines")

      html = render(index_live)
      assert html =~ "Animal criado com sucesso"
      assert html =~ "some name"
    end

    test "updates bovine in listing", %{conn: conn, bovine: bovine, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/bovines")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#bovines-#{bovine.id} a", "Editar")
               |> render_click()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/bovines/#{bovine}/edit")

      assert render(form_live) =~ "Editar"

      assert form_live
             |> form("#bovine-form", bovine: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#bovine-form", bovine: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/bovines")

      html = render(index_live)
      assert html =~ "Animal editado com sucesso"
      assert html =~ "some updated name"
    end

    test "deletes bovine in listing", %{conn: conn, bovine: bovine, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/bovines")

      assert index_live |> element("#bovines-#{bovine.id} a", "Deletar") |> render_click()
      refute has_element?(index_live, "#bovines-#{bovine.id}")
    end
  end

  describe "Show" do
    setup [:create_bovine]

    test "displays bovine", %{conn: conn, bovine: bovine, scope: scope} do
      {:ok, _show_live, html} = live(conn, ~p"/o/#{scope.organization.slug}/bovines/#{bovine}")

      assert html =~ "Animal"
      assert html =~ bovine.name
    end

    test "updates bovine and returns to show", %{conn: conn, bovine: bovine, scope: scope} do
      {:ok, show_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/bovines/#{bovine}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Editar")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/o/#{scope.organization.slug}/bovines/#{bovine}/edit?return_to=show"
               )

      assert render(form_live) =~ "Editar"

      assert form_live
             |> form("#bovine-form", bovine: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#bovine-form", bovine: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/bovines/#{bovine}")

      html = render(show_live)
      assert html =~ "Animal editado com sucesso"
      assert html =~ "some updated name"
    end
  end
end
