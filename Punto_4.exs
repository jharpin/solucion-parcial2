defmodule EliminadorDuplicados do
  def eliminar_duplicados(piezas) do
    piezas_invertidas = invertir_lista(piezas, [])
    resultado = eliminar_dup_rec(piezas_invertidas, [], [])
    invertir_lista(resultado, [])
  end

  defp eliminar_dup_rec([], _codigos_vistos, acumulador), do: acumulador

  defp eliminar_dup_rec([pieza | resto], codigos_vistos, acumulador) do
    if codigo_ya_visto(pieza.codigo, codigos_vistos) do
      eliminar_dup_rec(resto, codigos_vistos, acumulador)
    else
      eliminar_dup_rec(resto, [pieza.codigo | codigos_vistos], [pieza | acumulador])
    end
  end

  defp codigo_ya_visto(_codigo, []), do: false
  defp codigo_ya_visto(codigo, [h | t]), do: codigo == h or codigo_ya_visto(codigo, t)

  defp invertir_lista([], acc), do: acc
  defp invertir_lista([h | t], acc), do: invertir_lista(t, [h | acc])
end
