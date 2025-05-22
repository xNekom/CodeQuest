import json
import uuid
import os

def load_json(file_path):
    """Carga datos desde un archivo JSON."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Error: Archivo no encontrado - {file_path}")
        return []
    except json.JSONDecodeError:
        print(f"Error: Formato JSON inválido en - {file_path}")
        return []

def save_json(file_path, data):
    """Guarda datos en un archivo JSON."""
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"Datos guardados exitosamente en {file_path}")
    except IOError:
        print(f"Error: No se pudo escribir en el archivo - {file_path}")

def generate_uuids_and_map(data_list, id_to_uuid_map):
    """
    Genera UUIDs para cada item en la lista, actualiza el 'id' del item,
    y puebla el mapeo de old_id -> new_uuid.
    """
    updated_data_list = []
    for item in data_list:
        old_id = item.get('id')
        if old_id is not None:
            new_uuid = str(uuid.uuid4())
            id_to_uuid_map[old_id] = new_uuid
            item['id'] = new_uuid
        else:
            print(f"Advertencia: Item sin 'id' encontrado: {item}. Se generará un UUID pero no habrá mapeo desde un old_id.")
            # Si no hay 'id' original, igual le asignamos un UUID para consistencia,
            # aunque no podrá ser referenciado por un 'old_id'.
            item['id'] = str(uuid.uuid4())
        updated_data_list.append(item)
    return updated_data_list

def update_references(data, id_to_uuid_map):
    """
    Actualiza recursivamente todas las cadenas que son IDs antiguos a sus nuevos UUIDs.
    """
    if isinstance(data, dict):
        for key, value in data.items():
            if isinstance(value, str) and value in id_to_uuid_map:
                data[key] = id_to_uuid_map[value]
            elif key.endswith('Id') and isinstance(value, str) and value in id_to_uuid_map: # Cubre prerequisiteMissionId, enemyId, itemId
                 data[key] = id_to_uuid_map[value]
            elif key.endswith('Ids') and isinstance(value, list): # Cubre questionIds
                data[key] = [id_to_uuid_map.get(item_id, item_id) for item_id in value]
            elif key == 'unlocks' and isinstance(value, list): # Cubre rewards.unlocks
                 data[key] = [id_to_uuid_map.get(unlock_id, unlock_id) for unlock_id in value]
            elif key == 'items' and isinstance(value, list) and 'itemId' in (value[0] if value else {}): # Cubre rewards.items
                for item_reward in value:
                    if 'itemId' in item_reward and item_reward['itemId'] in id_to_uuid_map:
                        item_reward['itemId'] = id_to_uuid_map[item_reward['itemId']]
            elif key == 'lootTable' and isinstance(value, list): # Cubre lootTable en enemies_data
                for loot_item in value:
                    if 'itemId' in loot_item and loot_item['itemId'] in id_to_uuid_map:
                        loot_item['itemId'] = id_to_uuid_map[loot_item['itemId']]
            else:
                update_references(value, id_to_uuid_map)
    elif isinstance(data, list):
        for i, item in enumerate(data):
            if isinstance(item, str) and item in id_to_uuid_map:
                data[i] = id_to_uuid_map[item]
            else:
                update_references(item, id_to_uuid_map)
    return data


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    items_file = os.path.join(script_dir, 'items_data.json')
    enemies_file = os.path.join(script_dir, 'enemies_data.json')
    questions_file = os.path.join(script_dir, 'questions.json')
    missions_file = os.path.join(script_dir, 'missions_data.json')

    id_to_uuid_map = {}

    # Cargar todos los datos y generar UUIDs para los IDs principales
    print("Procesando items...")
    items_data = load_json(items_file)
    items_data = generate_uuids_and_map(items_data, id_to_uuid_map)

    print("Procesando enemigos...")
    enemies_data = load_json(enemies_file)
    enemies_data = generate_uuids_and_map(enemies_data, id_to_uuid_map)
    
    print("Procesando preguntas...")
    questions_data = load_json(questions_file)
    questions_data = generate_uuids_and_map(questions_data, id_to_uuid_map)

    print("Procesando misiones...")
    missions_data = load_json(missions_file)
    missions_data = generate_uuids_and_map(missions_data, id_to_uuid_map)

    # Imprimir el mapa para depuración (opcional)
    # print("\nMapa de IDs antiguos a UUIDs nuevos:")
    # for old, new in id_to_uuid_map.items():
    #     print(f"  '{old}': '{new}'")
    # print("-" * 30)

    # Actualizar referencias en los datos cargados
    print("\nActualizando referencias en los datos de misiones...")
    missions_data = update_references(missions_data, id_to_uuid_map)
    
    print("Actualizando referencias en los datos de enemigos...")
    enemies_data = update_references(enemies_data, id_to_uuid_map)
    
    # Items y Questions generalmente no tienen referencias a otros, pero por si acaso:
    print("Actualizando referencias en los datos de items (si aplica)...")
    items_data = update_references(items_data, id_to_uuid_map)
    
    print("Actualizando referencias en los datos de preguntas (si aplica)...")
    questions_data = update_references(questions_data, id_to_uuid_map)

    # Guardar los datos actualizados
    print("\nGuardando archivos JSON actualizados...")
    save_json(items_file, items_data)
    save_json(enemies_file, enemies_data)
    save_json(questions_file, questions_data)
    save_json(missions_file, missions_data)

    print("\nProceso completado. Todos los archivos JSON deberían estar actualizados con UUIDs y referencias corregidas.")

if __name__ == '__main__':
    main()
