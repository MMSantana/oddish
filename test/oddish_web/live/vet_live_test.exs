defmodule OddishWeb.VetLiveTest do
  use OddishWeb.ConnCase

  import Phoenix.LiveViewTest
  import Oddish.MedicineFixtures

  @create_attrs %{name: "some name", telephone: "some telephone", email: "some email"}
  @update_attrs %{
    name: "some updated name",
    telephone: "some updated telephone",
    email: "some updated email"
  }
  @invalid_attrs %{name: nil, telephone: nil, email: nil}

  setup :register_and_log_in_user_with_org

  defp create_vet(%{scope: scope}) do
    vet = vet_fixture(scope)

    %{vet: vet}
  end

  describe "Index" do
    setup [:create_vet]

    test "lists all vets", %{conn: conn, vet: vet, scope: scope} do
      {:ok, _index_live, html} = live(conn, ~p"/o/#{scope.organization.slug}/vets")

      assert html =~ "Listando Veterinários"
      assert html =~ vet.name
    end

    test "saves new vet", %{conn: conn, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/vets")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "Novo Veterinário")
               |> render_click()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/vets/new")

      assert render(form_live) =~ "Novo Veterinário"

      assert form_live
             |> form("#vet-form", vet: @invalid_attrs)
             |> render_change() =~ "Não pode estar em branco"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#vet-form", vet: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/vets")

      html = render(index_live)
      assert html =~ "Veterinário criado com sucesso"
      assert html =~ "some name"
    end

    test "updates vet in listing", %{conn: conn, vet: vet, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/vets")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#vets-#{vet.id} a", "Editar")
               |> render_click()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/vets/#{vet}/edit")

      assert render(form_live) =~ "Editar Veterinário"

      assert form_live
             |> form("#vet-form", vet: @invalid_attrs)
             |> render_change() =~ "Não pode estar em branco"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#vet-form", vet: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/vets")

      html = render(index_live)
      assert html =~ "Veterinário atualizado com sucesso"
      assert html =~ "some updated name"
    end

    test "deletes vet in listing", %{conn: conn, vet: vet, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/vets")

      assert index_live |> element("#vets-#{vet.id} a", "Excluir") |> render_click()
      refute has_element?(index_live, "#vets-#{vet.id}")
    end
  end

  describe "Show" do
    setup [:create_vet]

    test "displays vet", %{conn: conn, vet: vet, scope: scope} do
      {:ok, _show_live, html} = live(conn, ~p"/o/#{scope.organization.slug}/vets/#{vet}")

      assert html =~ "Ver Veterinário"
      assert html =~ vet.name
    end

    test "updates vet and returns to show", %{conn: conn, vet: vet, scope: scope} do
      {:ok, show_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/vets/#{vet}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Editar")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/o/#{scope.organization.slug}/vets/#{vet}/edit?return_to=show"
               )

      assert render(form_live) =~ "Editar Veterinário"

      assert form_live
             |> form("#vet-form", vet: @invalid_attrs)
             |> render_change() =~ "Não pode estar em branco"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#vet-form", vet: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/vets/#{vet}")

      html = render(show_live)
      assert html =~ "Veterinário atualizado com sucesso"
      assert html =~ "some updated name"
    end
  end
end
