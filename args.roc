app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.10.0/vNe6s9hWzoTZtFmNkvEICPErI9ptji_ySjicO6CkucY.tar.br" }

import pf.Stdout
import pf.File
import pf.Task
import pf.Path
import pf.Utc
import pf.Arg

main =
    finalTask =
        # try to read the first command line argument
        pathArg = readFirstArgT!

        readFileToStr (Path.fromStr pathArg)

    finalResult <- Task.attempt finalTask

    when finalResult is
        Err ZeroArgsGiven ->
            Task.err (Exit 1 "Error ZeroArgsGiven")

        Err (ReadFileErr errMsg) ->
            Task.err (Exit 1 "Error ReadFileErr:\n$(errMsg)")

        Ok fileContentStr ->
            parseTime = Utc.now!
            dict = fileContentStr |> parse
            parseEndTime = Utc.now!
            runTime = Utc.deltaAsMillis parseTime parseEndTime |> Num.toStr
            Stdout.line! "Dict length: $(Dict.len dict |> Num.toStr)"
            Stdout.line! "File parsed in $(runTime)ms"

        _ ->
            Task.err (Exit 1 "Unknown error")

readFirstArgT =
    args = Arg.list!
    List.get args 1 |> Result.mapErr (\_ -> ZeroArgsGiven) |> Task.fromResult

readFileToStr = \path ->
    path
    |> File.readUtf8
    |> Task.mapErr \_ -> ReadFileErr "Failed to read file: $(Inspect.toStr path)"

parse = \contents ->
    citiesList = Str.split contents "\n"

    List.walk citiesList (Dict.empty {}) \state, elem ->
        cityWithTemp = Str.split elem ";"
        [city, t] = cityWithTemp
        temp = Result.withDefault (Str.toF32 t) 0

        Dict.update state city \value ->
            when value is
                Missing -> Present { min: temp, mean: temp, max: temp }
                Present { min: oldMin, mean: oldMean, max: oldMax } ->
                    Present {
                        min: Num.min temp oldMin,
                        mean: (temp + oldMean) / 2,
                        max: Num.max temp oldMax,
                    }
