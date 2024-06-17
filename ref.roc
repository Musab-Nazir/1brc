app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.10.0/vNe6s9hWzoTZtFmNkvEICPErI9ptji_ySjicO6CkucY.tar.br" }

import pf.Stdout
import pf.Task
import pf.File
import pf.Path
import pf.Utc

main =
    startTime = Utc.now!
    input <- File.readUtf8 (Path.fromStr "measurements1M.txt") |> Task.attempt
    when input is
        Ok s ->
            endTime = Utc.now!
            readTime = Utc.deltaAsMillis startTime endTime |> Num.toStr
            parseTime = Utc.now!
            dict = s |> Str.split "\n" |> List.walkWithIndex (Dict.empty {}) insertToDict
            parseEndTime = Utc.now!
            runTime = Utc.deltaAsMillis parseTime parseEndTime |> Num.toStr
            Stdout.line! "Dict length: $(Dict.len dict |> Num.toStr)"
            Stdout.line! "File read in $(readTime)ms\nFile parsed in $(runTime)ms"

        Err _ -> Stdout.line! "Failed to read file"

insertToDict = \dict, readingLine, _ ->
    when Str.split readingLine ";" is
        [station, valStr] ->
            when Str.toF32 valStr is
                Ok temp ->
                    Dict.update dict station \value ->
                        when value is
                            Missing -> Present { min: temp, mean: temp, max: temp }
                            Present { min: oldMin, mean: oldMean, max: oldMax } ->
                                Present {
                                    min: Num.min temp oldMin,
                                    mean: (temp + oldMean) / 2,
                                    max: Num.max temp oldMax,
                                }

                Err _ -> dict

        _ -> dict
