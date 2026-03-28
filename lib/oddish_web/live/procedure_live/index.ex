defmodule OddishWeb.ProcedureLive.Index do
  use OddishWeb, :live_view

  alias Oddish.Medicine

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listando Procedimentos
        <:actions>
          <.button
            variant="primary"
            navigate={~p"/o/#{@current_scope.organization.slug}/procedures/new"}
          >
            <.icon name="hero-plus" /> Novo Procedimento
          </.button>
        </:actions>
      </.header>

      <.table
        id="procedures"
        rows={@streams.procedures}
        row_click={
          fn {_id, procedure} ->
            JS.navigate(~p"/o/#{@current_scope.organization.slug}/procedures/#{procedure}")
          end
        }
      >
        <:col :let={{_id, procedure}} label="Nome">{procedure.name}</:col>
        <:col :let={{_id, procedure}} label="Tipo">{procedure.kind}</:col>
        <:action :let={{_id, procedure}}>
          <div class="sr-only">
            <.link navigate={~p"/o/#{@current_scope.organization.slug}/procedures/#{procedure}"}>
              Ver
            </.link>
          </div>
          <.link navigate={~p"/o/#{@current_scope.organization.slug}/procedures/#{procedure}/edit"}>
            Editar
          </.link>
        </:action>
        <:action :let={{id, procedure}}>
          <.link
            phx-click={JS.push("delete", value: %{id: procedure.id}) |> hide("##{id}")}
            data-confirm="Tem certeza?"
          >
            Excluir
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Medicine.subscribe_procedures(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listando Procedimentos")
     |> stream(:procedures, list_procedures(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    procedure = Medicine.get_procedure!(socket.assigns.current_scope, id)
    {:ok, _} = Medicine.delete_procedure(socket.assigns.current_scope, procedure)

    {:noreply, stream_delete(socket, :procedures, procedure)}
  end

  @impl true
  def handle_info({type, %Oddish.Medicine.Procedure{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :procedures, list_procedures(socket.assigns.current_scope), reset: true)}
  end

  defp list_procedures(current_scope) do
    Medicine.list_procedures(current_scope)
  end
end
