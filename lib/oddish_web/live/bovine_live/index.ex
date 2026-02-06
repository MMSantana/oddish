defmodule OddishWeb.BovineLive.Index do
  use OddishWeb, :live_view

  alias Oddish.Cattle

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Bovinos
        <:actions>
          <.button variant="primary" navigate={~p"/o/#{@current_scope.organization.slug}/bovines/new"}>
            <.icon name="hero-plus" /> Novo Bovino
          </.button>
        </:actions>
      </.header>

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
        <:col :let={{_id, bovine}} label="Gênero">{bovine.gender}</:col>
        <:col :let={{_id, bovine}} label="Mãe">{bovine.mother_id}</:col>
        <:col :let={{_id, bovine}} label="Data de nascimento">{bovine.date_of_birth}</:col>
        <:col :let={{_id, bovine}} label="Descrição">{bovine.description}</:col>
        <:col :let={{_id, bovine}} label="Observação">{bovine.observation}</:col>
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
            data-confirm="Tem certeza que deseja excluir este boi?"
          >
            Deletar
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Cattle.subscribe_bovines(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Bovinos")
     |> stream(:bovines, list_bovines(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bovine = Cattle.get_bovine!(socket.assigns.current_scope, id)
    {:ok, _} = Cattle.delete_bovine(socket.assigns.current_scope, bovine)

    {:noreply, stream_delete(socket, :bovines, bovine)}
  end

  @impl true
  def handle_info({type, %Oddish.Cattle.Bovine{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :bovines, list_bovines(socket.assigns.current_scope), reset: true)}
  end

  defp list_bovines(current_scope) do
    Cattle.list_bovines(current_scope)
  end
end
