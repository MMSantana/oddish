defmodule OddishWeb.BovineLive.Index do
  use OddishWeb, :live_view

  alias Oddish.Cattle

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Animais
        <:actions>
          <.button variant="primary" navigate={~p"/o/#{@current_scope.organization.slug}/bovines/new"}>
            <.icon name="hero-plus" /> Novo
          </.button>
        </:actions>
      </.header>

      <.form
        for={@name_number_form}
        id="search-form"
        phx-change="search"
        phx-submit="search"
      >
        <.input field={@name_number_form[:query]} type="text" label="Nome" phx-debounce="500" />
      </.form>

      <.table
        id="bovines"
        rows={@streams.bovines}
        row_click={
          fn {_id, bovine} ->
            JS.navigate(~p"/o/#{@current_scope.organization.slug}/bovines/#{bovine}")
          end
        }
      >
        <:col :let={{_id, bovine}} label="Nome">{bovine.name}</:col>
        <:col :let={{_id, bovine}} label="Número de registro">{bovine.registration_number}</:col>
        <:col :let={{_id, bovine}} label="Gênero">
          {Oddish.Cattle.Bovine.present_gender(bovine.gender)}
        </:col>
        <:col :let={{_id, bovine}} label="Lote">{display_pack(bovine)}</:col>
        <:col :let={{_id, bovine}} label="Data de nascimento">{bovine.date_of_birth}</:col>
        <:action :let={{_id, bovine}}>
          <div class="sr-only">
            <.link navigate={~p"/o/#{@current_scope.organization.slug}/bovines/#{bovine}"}>
              Show
            </.link>
          </div>
          <.link navigate={~p"/o/#{@current_scope.organization.slug}/bovines/#{bovine}/edit"}>
            Editar
          </.link>
        </:action>
        <:action :let={{id, bovine}}>
          <.link
            phx-click={JS.push("delete", value: %{id: bovine.id}) |> hide("##{id}")}
            data-confirm="Tem certeza que deseja excluir este animal?"
          >
            Deletar
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket) do
      Cattle.subscribe_bovines(socket.assigns.current_scope)
    end

    query = params["query"] || ""

    {:ok,
     socket
     |> assign(:page_title, "Animais")
     |> assign(:name_number_form, to_form(%{"query" => query}))
     |> stream(:bovines, list_bovines(socket.assigns.current_scope))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    query = get_in(params, ["query", "query"]) || params["query"] || ""

    socket
    |> assign(:name_number_form, to_form(%{"query" => query}))
    |> stream(:bovines, Oddish.Cattle.name_number_search(socket.assigns.current_scope, query),
      reset: true
    )
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bovine = Cattle.get_bovine!(socket.assigns.current_scope, id)
    {:ok, _} = Cattle.delete_bovine(socket.assigns.current_scope, bovine)

    {:noreply, stream_delete(socket, :bovines, bovine)}
  end

  @impl true
  def handle_event("search", query, socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/o/#{socket.assigns.current_scope.organization.slug}/bovines?#{%{query: query}}"
     )}
  end

  @impl true
  def handle_info({type, %Oddish.Cattle.Bovine{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :bovines, list_bovines(socket.assigns.current_scope), reset: true)}
  end

  defp list_bovines(current_scope) do
    Cattle.list_bovines(current_scope) |> Oddish.Repo.preload(:pack)
  end

  defp display_pack(%{pack: %{name: name}}), do: name
  defp display_pack(_), do: "--"
end
