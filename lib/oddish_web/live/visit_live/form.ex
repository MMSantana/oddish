defmodule OddishWeb.VisitLive.Form do
  use OddishWeb, :live_view

  alias Oddish.Medicine
  alias Oddish.Medicine.Visit

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use este formulário para gerenciar visitas no banco de dados.</:subtitle>
      </.header>

      <.form for={@form} id="visit-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:vet_id]}
          type="select"
          options={Enum.map(@vets, &{&1.name, &1.id})}
          label="Veterinário"
          prompt="Selecione um veterinário"
        />
        <.input
          field={@form[:procedure_id]}
          type="select"
          options={Enum.map(@procedures, &{&1.name, &1.id})}
          label="Procedimento"
          prompt="Selecione um procedimento"
        />

        <div class="mt-4">
          <label class="block text-sm font-medium leading-6 text-zinc-800">Bovinos</label>
          <div class="mt-2 flex flex-wrap gap-2">
            <%= for bovine <- @selected_bovines do %>
              <div class="inline-flex items-center gap-x-1.5 rounded-md px-2 py-1 text-sm font-medium ring-1 ring-inset ring-gray-200 bg-white">
                {bovine.registration_number} - {bovine.name}
                <button
                  type="button"
                  phx-click="remove_bovine"
                  phx-value-id={bovine.id}
                  class="group relative -mr-1 h-4 w-4 rounded-sm hover:bg-gray-200 flex items-center justify-center"
                >
                  <.icon name="hero-x-mark" class="h-3 w-3" />
                </button>
                <input type="hidden" name="visit[bovine_ids][]" value={bovine.id} />
              </div>
            <% end %>
            <input type="hidden" name="visit[bovine_ids][]" value="" />
          </div>

          <div class="mt-2 relative">
            <.input
              name="search_bovine"
              value=""
              type="text"
              placeholder="Buscar por número de registro ou nome..."
              phx-keyup="search_bovine"
              phx-debounce="300"
            />
            <%= if length(@search_results) > 0 do %>
              <ul class="absolute z-10 w-full bg-white shadow-lg max-h-60 rounded-md py-1 text-base overflow-auto sm:text-sm ring-1 ring-black ring-opacity-5">
                <%= for bovine <- @search_results do %>
                  <li
                    class="cursor-pointer select-none relative py-2 pl-3 pr-9 hover:bg-gray-100"
                    phx-click="add_bovine"
                    phx-value-id={bovine.id}
                  >
                    <div class="flex items-center">
                      <span class="font-normal block truncate">
                        {bovine.registration_number} - {bovine.name}
                      </span>
                    </div>
                  </li>
                <% end %>
              </ul>
            <% end %>
          </div>
        </div>

        <.input field={@form[:date]} type="date" label="Data" />
        <.input field={@form[:paid?]} type="checkbox" label="Pago?" />
        <.input field={@form[:notes]} type="textarea" label="Observações" />
        <footer>
          <.button phx-disable-with="Salvando..." variant="primary">Salvar Visita</.button>
          <.button navigate={return_path(@current_scope, @return_to, @visit)}>Cancelar</.button>
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
    visit = Medicine.get_visit!(socket.assigns.current_scope, id)
    vets = Medicine.list_vets(socket.assigns.current_scope)
    procedures = Medicine.list_procedures(socket.assigns.current_scope)

    socket
    |> assign(:page_title, "Editar Visita")
    |> assign(:visit, visit)
    |> assign(:form, to_form(Medicine.change_visit(socket.assigns.current_scope, visit)))
    |> assign(:selected_bovines, visit.bovines)
    |> assign(:search_results, [])
    |> assign(:vets, vets)
    |> assign(:procedures, procedures)
  end

  defp apply_action(socket, :new, _params) do
    visit = %Visit{org_id: socket.assigns.current_scope.organization.id}
    vets = Medicine.list_vets(socket.assigns.current_scope)
    procedures = Medicine.list_procedures(socket.assigns.current_scope)

    socket
    |> assign(:page_title, "Nova Visita")
    |> assign(:visit, visit)
    |> assign(:form, to_form(Medicine.change_visit(socket.assigns.current_scope, visit)))
    |> assign(:selected_bovines, [])
    |> assign(:search_results, [])
    |> assign(:vets, vets)
    |> assign(:procedures, procedures)
  end

  @impl true
  def handle_event("validate", %{"visit" => visit_params}, socket) do
    changeset =
      Medicine.change_visit(socket.assigns.current_scope, socket.assigns.visit, visit_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"visit" => visit_params}, socket) do
    save_visit(socket, socket.assigns.live_action, visit_params)
  end

  def handle_event("search_bovine", %{"value" => q}, socket) do
    if String.length(q) > 0 do
      selected_ids = Enum.map(socket.assigns.selected_bovines, & &1.id)

      bovines =
        Oddish.Cattle.name_number_search(socket.assigns.current_scope, q)
        |> Enum.reject(&(&1.id in selected_ids))

      {:noreply, assign(socket, search_results: bovines)}
    else
      {:noreply, assign(socket, search_results: [])}
    end
  end

  def handle_event("add_bovine", %{"id" => id}, socket) do
    bovine = Enum.find(socket.assigns.search_results, fn b -> to_string(b.id) == id end)

    selected = socket.assigns.selected_bovines

    selected =
      if bovine && !Enum.find(selected, &(&1.id == bovine.id)),
        do: [bovine | selected],
        else: selected

    {:noreply, assign(socket, selected_bovines: selected, search_results: [])}
  end

  def handle_event("remove_bovine", %{"id" => id}, socket) do
    selected = Enum.reject(socket.assigns.selected_bovines, fn b -> to_string(b.id) == id end)
    {:noreply, assign(socket, selected_bovines: selected)}
  end

  defp save_visit(socket, :edit, visit_params) do
    case Medicine.update_visit(socket.assigns.current_scope, socket.assigns.visit, visit_params) do
      {:ok, visit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Visita atualizada com sucesso")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, visit)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_visit(socket, :new, visit_params) do
    case Medicine.create_visit(socket.assigns.current_scope, visit_params) do
      {:ok, visit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Visita criada com sucesso")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, visit)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(scope, "index", _visit), do: ~p"/o/#{scope.organization.slug}/visits"
  defp return_path(scope, "show", visit), do: ~p"/o/#{scope.organization.slug}/visits/#{visit}"
end
