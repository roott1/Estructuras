import pandas as pd
import numpy as np

# Leer el archivo CSV
filename = 'resultados_TH.csv'
data = pd.read_csv(filename)

# Filtrar las filas donde ningún valor de TH es mayor que 1
th_columns = [col for col in data.columns if col.startswith('TH')]
condition = (data[th_columns] <= 1).all(axis=1)
filtered_data = data[condition]

# Calcular la raíz de la sumatoria de TH al cuadrado
def raiz_sumatoria_th(row, th_columns):
    th_values = row[th_columns].values
    return np.sqrt(np.sum(th_values ** 2))

# Aplicar la función para calcular la raíz de la sumatoria de TH al cuadrado
filtered_data['Raiz_Sumatoria_TH'] = filtered_data.apply(lambda row: raiz_sumatoria_th(row, th_columns), axis=1)

# Encontrar el valor mínimo de la raíz de la sumatoria de TH al cuadrado
min_raiz_sumatoria = filtered_data['Raiz_Sumatoria_TH'].min()

# Filtrar las filas basadas en la raíz de la sumatoria de TH al cuadrado
final_filtered_data = filtered_data[filtered_data['Raiz_Sumatoria_TH'] == min_raiz_sumatoria]

# Mostrar el DataFrame filtrado
print("Filas con la menor raíz de la sumatoria de TH al cuadrado:")
print(final_filtered_data)

# Opcional: guardar los resultados filtrados en un nuevo archivo CSV
filtered_filename = 'resultados_finales.csv'
final_filtered_data.to_csv(filtered_filename, index=False)
print(f"Resultados finales guardados en {filtered_filename}")
