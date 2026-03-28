defmodule OddishWeb.ProcedureLive.Show do
  use OddishWeb, :live_view

  alias Oddish.Medicine

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Procedimento {@procedure.id}
        <:subtitle>Este é um registro de procedimento do seu banco de dados.</:subtitle>
        <:actions>
          <.button navigate={~p"/o/#{@current_scope.organization.slug}/procedures"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={
              ~p"/o/#{@current_scope.organization.slug}/procedures/#{@procedure}/edit?return_to=show"
            }
          >
            <.icon name="hero-pencil-square" /> Editar procedimento
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Nome">{@procedure.name}</:item>
        <:item title="Tipo">{@procedure.kind}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Medicine.subscribe_procedures(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Ver Procedimento")
     |> assign(:procedure, Medicine.get_procedure!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Oddish.Medicine.Procedure{id: id} = procedure},
        %{assigns: %{procedure: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :procedure, procedure)}
  end

  def handle_info(
        {:deleted, %Oddish.Medicine.Procedure{id: id}},
        %{assigns: %{procedure: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "O procedimento atual foi excluído.")
     |> push_navigate(to: ~p"/o/#{socket.assigns.current_scope.organization.slug}/procedures")}
  end

  def handle_info({type, %Oddish.Medicine.Procedure{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
