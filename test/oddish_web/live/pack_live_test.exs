defmodule OddishWeb.PackLiveTest do
  use OddishWeb.ConnCase

  import Phoenix.LiveViewTest
  import Oddish.PacksFixtures

  @create_attrs %{name: "some name", status: :active, flock_type: :bezerros, animal_count: 42}
  @update_attrs %{
    name: "some updated name",
    status: :inactive,
    flock_type: :bois,
    animal_count: 43
  }
  @invalid_attrs %{name: nil, status: nil, flock_type: nil, animal_count: nil}

  setup :register_and_log_in_user_with_org

  defp create_pack(%{scope: scope}) do
    pack = pack_fixture(scope)

    %{pack: pack}
  end

  describe "Index" do
    setup [:create_pack]

    test "lists all packs", %{conn: conn, pack: pack, scope: scope} do
      {:ok, _index_live, html} = live(conn, ~p"/o/#{scope.organization.slug}/packs")

      assert html =~ "Listing Packs"
      assert html =~ pack.name
    end

    test "saves new pack", %{conn: conn, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/packs")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Pack")
               |> render_click()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/packs/new")

      assert render(form_live) =~ "New Pack"

      assert form_live
             |> form("#pack-form", pack: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#pack-form", pack: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/packs")

      html = render(index_live)
      assert html =~ "Pack created successfully"
      assert html =~ "some name"
    end

    test "updates pack in listing", %{conn: conn, pack: pack, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/packs")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#packs-#{pack.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/packs/#{pack}/edit")

      assert render(form_live) =~ "Edit Pack"

      assert form_live
             |> form("#pack-form", pack: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#pack-form", pack: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/packs")

      html = render(index_live)
      assert html =~ "Pack updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes pack in listing", %{conn: conn, pack: pack, scope: scope} do
      {:ok, index_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/packs")

      assert index_live |> element("#packs-#{pack.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#packs-#{pack.id}")
    end
  end

  describe "Show" do
    setup [:create_pack]

    test "displays pack", %{conn: conn, pack: pack, scope: scope} do
      {:ok, _show_live, html} = live(conn, ~p"/o/#{scope.organization.slug}/packs/#{pack}")

      assert html =~ "Show Pack"
      assert html =~ pack.name
    end

    test "updates pack and returns to show", %{conn: conn, pack: pack, scope: scope} do
      {:ok, show_live, _html} = live(conn, ~p"/o/#{scope.organization.slug}/packs/#{pack}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/o/#{scope.organization.slug}/packs/#{pack}/edit?return_to=show"
               )

      assert render(form_live) =~ "Edit Pack"

      assert form_live
             |> form("#pack-form", pack: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#pack-form", pack: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/o/#{scope.organization.slug}/packs/#{pack}")

      html = render(show_live)
      assert html =~ "Pack updated successfully"
      assert html =~ "some updated name"
    end
  end
end
