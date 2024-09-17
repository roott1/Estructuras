import itertools

n = 5
incrementos = 30
# Definir el rango de ángulos con incrementos de 15 grados
angles = list(range(-90, 91, incrementos))

# Generar todas las combinaciones posibles de n ángulos
combinations = list(itertools.product(angles, repeat=n))

# Guardar las combinaciones en un archivo de texto sin paréntesis
with open("combinaciones_angulos.txt", "w") as file:
    for comb in combinations:
        file.write(', '.join(map(str, comb)) + '\n')
print("Las combinaciones se han guardado en 'combinaciones_angulos.txt'.")

M = 1000
momentos = []
# Generar los valores con incrementos de 10
for x in range(0, M+1, 10):
    momentos.append(f"0, {x}, 0")

# Guardar los momentos en un archivo de texto
with open("momentos.txt", "w") as file:
    for momento in momentos:
        file.write(momento + '\n')

print("Los momentos se han guardado en 'momentos.txt'.")

