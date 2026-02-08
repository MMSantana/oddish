defmodule OddishWeb.PackLive.Index do
  use OddishWeb, :live_view

  alias Oddish.Packs

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Lotes
        <:actions>
          <.button variant="primary" navigate={~p"/o/#{@current_scope.organization.slug}/packs/new"}>
            <.icon name="hero-plus" /> Novo Lote
          </.button>
        </:actions>
      </.header>

      <.table
        id="packs"
        rows={@streams.packs}
        row_click={
          fn {_id, pack} -> JS.navigate(~p"/o/#{@current_scope.organization.slug}/packs/#{pack}") end
        }
      >
        <:col :let={{_id, pack}} label="Nome">{pack.name}</:col>
        <:col :let={{_id, pack}} label="Tipo de rebanho">
          {Oddish.Packs.Pack.present_flock_type(pack.flock_type)}
        </:col>
        <:col :let={{_id, pack}} label="Quantidade de animais">{pack.animal_count}</:col>
        <:col :let={{_id, pack}} label="Status">{Oddish.Packs.Pack.present_status(pack.status)}</:col>
        <:action :let={{_id, pack}}>
          <div class="sr-only">
            <.link navigate={~p"/o/#{@current_scope.organization.slug}/packs/#{pack}"}>Show</.link>
          </div>
          <.link navigate={~p"/o/#{@current_scope.organization.slug}/packs/#{pack}/edit"}>
            Editar
          </.link>
        </:action>
        <:action :let={{id, pack}}>
          <.link
            phx-click={JS.push("delete", value: %{id: pack.id}) |> hide("##{id}")}
            data-confirm="Tem certeza que deseja excluir este lote?"
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
      Packs.subscribe_packs(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Lotes")
     |> stream(:packs, list_packs(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    pack = Packs.get_pack!(socket.assigns.current_scope, id)
    {:ok, _} = Packs.delete_pack(socket.assigns.current_scope, pack)

    {:noreply, stream_delete(socket, :packs, pack)}
  end

  @impl true
  def handle_info({type, %Oddish.Packs.Pack{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :packs, list_packs(socket.assigns.current_scope), reset: true)}
  end

  defp list_packs(current_scope) do
    Packs.list_packs(current_scope)
  end
end
