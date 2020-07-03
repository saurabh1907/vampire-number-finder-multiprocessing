require Integer
defmodule Vampire do

    def find_vampire(chunk_list) do
        fangs_list = Enum.map chunk_list, fn x ->
                num_of_digits = x |> Integer.digits() |> length()
                if (Integer.is_even(num_of_digits)) do
                    get_fangs(x)
                end
        end
        Enum.filter(fangs_list, fn x -> x != nil end)
    end

    def get_fangs(num) do
        full_list = Enum.uniq(calc_permute(num))

        fangs_list = Enum.map full_list, fn permutation ->
            permutationStr = List.to_string(permutation)
            length = String.length(permutationStr)
            first_half = permutationStr |> String.slice(0,div(length, 2))
            firstInt = String.to_integer(first_half);
            second_half = permutationStr |> String.slice(div(length, 2)..-1)
            secondInt = String.to_integer(second_half)
            if(firstInt < secondInt && !(rem(firstInt,10) == 0 && rem(secondInt, 10) == 0) && firstInt * secondInt == num) do
                permutation = [firstInt, secondInt]
            end
        end
        fangs_list = Enum.uniq(fangs_list)
        if Enum.count(fangs_list) > 1 do
            fangs_list = Enum.filter(fangs_list, fn x -> x != nil && x != false end)
            fangs_list = List.flatten(fangs_list)
            fangs_list = [num | fangs_list]
        end
    end

    defp combinations([]), do: [[]]
    defp combinations(list), do: for elem <- list, rest <- combinations(list--[elem]), do: [elem|rest]

    defp calc_permute(num) do
        num_list = num |> Integer.to_string() |> String.codepoints()
        combinations(num_list)
    end
end
