defmodule OddishWeb.SoltaLive.Index do
  use OddishWeb, :live_view

  alias Oddish.Soltas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Soltas
        <:actions>
          <.button variant="primary" navigate={~p"/o/#{@current_scope.organization.slug}/soltas/new"}>
            <.icon name="hero-plus" /> Nova solta
          </.button>
        </:actions>
      </.header>

      <.table
        id="soltas"
        rows={@streams.soltas}
        row_click={
          fn {_id, solta} ->
            JS.navigate(~p"/o/#{@current_scope.organization.slug}/soltas/#{solta}")
          end
        }
      >
        <:col :let={{_id, solta}} label="Nome">{solta.name}</:col>
        <:col :let={{_id, solta}} label="Área">{solta.area}</:col>
        <:col :let={{_id, solta}} label="Tipo de capim">{solta.grass_type}</:col>
        <:action :let={{_id, solta}}>
          <div class="sr-only">
            <.link navigate={~p"/o/#{@current_scope.organization.slug}/soltas/#{solta}"}>Show</.link>
          </div>
          <.link navigate={~p"/o/#{@current_scope.organization.slug}/soltas/#{solta}/edit"}>
            Edit
          </.link>
        </:action>
        <:action :let={{id, solta}}>
          <.link
            phx-click={JS.push("delete", value: %{id: solta.id}) |> hide("##{id}")}
            data-confirm="Tem certeza que deseja deletar esta solta?"
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
      Soltas.subscribe_soltas(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Soltas")
     |> stream(:soltas, list_soltas(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    solta = Soltas.get_solta!(socket.assigns.current_scope, id)
    {:ok, _} = Soltas.delete_solta(socket.assigns.current_scope, solta)

    {:noreply, stream_delete(socket, :soltas, solta)}
  end

  @impl true
  def handle_info({type, %Oddish.Soltas.Solta{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :soltas, list_soltas(socket.assigns.current_scope), reset: true)}
  end

  defp list_soltas(current_scope) do
    Soltas.list_soltas(current_scope)
  end
end
