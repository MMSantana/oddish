defmodule OddishWeb.ProcedureLive.Form do
  use OddishWeb, :live_view

  alias Oddish.Medicine
  alias Oddish.Medicine.Procedure

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use este formulário para gerenciar procedimentos no banco de dados.</:subtitle>
      </.header>

      <.form for={@form} id="procedure-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Nome" />
        <.input
          field={@form[:kind]}
          type="select"
          label="Tipo"
          prompt="--"
          options={
            Ecto.Enum.values(Oddish.Medicine.Procedure, :kind)
            |> Enum.map(fn status -> {Oddish.Medicine.Procedure.present_type(status), status} end)
          }
        />
        <footer>
          <.button phx-disable-with="Salvando..." variant="primary">Salvar Procedimento</.button>
          <.button navigate={return_path(@current_scope, @return_to, @procedure)}>Cancelar</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    procedure = Medicine.get_procedure!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Editar Procedimento")
    |> assign(:procedure, procedure)
    |> assign(:form, to_form(Medicine.change_procedure(socket.assigns.current_scope, procedure)))
  end

  defp apply_action(socket, :new, _params) do
    procedure = %Procedure{org_id: socket.assigns.current_scope.organization.id}

    socket
    |> assign(:page_title, "Novo Procedimento")
    |> assign(:procedure, procedure)
    |> assign(:form, to_form(Medicine.change_procedure(socket.assigns.current_scope, procedure)))
  end

  @impl true
  def handle_event("validate", %{"procedure" => procedure_params}, socket) do
    changeset =
      Medicine.change_procedure(
        socket.assigns.current_scope,
        socket.assigns.procedure,
        procedure_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"procedure" => procedure_params}, socket) do
    save_procedure(socket, socket.assigns.live_action, procedure_params)
  end

  defp save_procedure(socket, :edit, procedure_params) do
    case Medicine.update_procedure(
           socket.assigns.current_scope,
           socket.assigns.procedure,
           procedure_params
         ) do
      {:ok, procedure} ->
        {:noreply,
         socket
         |> put_flash(:info, "Procedimento atualizado com sucesso")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, procedure)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_procedure(socket, :new, procedure_params) do
    case Medicine.create_procedure(socket.assigns.current_scope, procedure_params) do
      {:ok, procedure} ->
        {:noreply,
         socket
         |> put_flash(:info, "Procedimento criado com sucesso")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, procedure)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(scope, "index", _procedure), do: ~p"/o/#{scope.organization.slug}/procedures"

  defp return_path(scope, "show", procedure),
    do: ~p"/o/#{scope.organization.slug}/procedures/#{procedure}"
end
