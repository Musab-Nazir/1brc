app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.10.0/vNe6s9hWzoTZtFmNkvEICPErI9ptji_ySjicO6CkucY.tar.br" }

import pf.Stdout
import pf.File
import pf.Task
import pf.Path
import pf.Utc
# import pf.Arg

# main =
#     finalTask =
#         pathArg = readFirstArgT!
#         readFileToStr pathArg

#     finalResult <- finalTask |> Task.attempt

#     when finalResult is
#         Err ZeroArgsGiven ->
#             Task.err (Exit 1 "Error ZeroArgsGiven")

#         Err (ReadFileErr errMsg) ->
#             Task.err (Exit 1 "Error ReadFileErr:\n$(errMsg)")

#         Ok fileContentStr ->
#             fileContentStr |> parse |> Inspect.toStr |> Stdout.line!

#         _ ->
#             Task.err (Exit 1 "Unknown error")


# readFirstArgT =
#     args = Arg.list!
#     List.get args 1 |> Result.mapErr (\_ -> ZeroArgsGiven) |> Task.fromResult

# readFileToStr = \path ->
#     path
#     |> File.readUtf8
#     |> Task.mapErr \_ -> ReadFileErr "Failed to read file: $(Inspect.toStr path)"

main =
    startTime = Utc.now!
    input <- File.readUtf8 (Path.fromStr "measurements1M.txt") |> Task.attempt
    when input is
        Ok s ->
            endTime = Utc.now!
            readTime = Utc.deltaAsMillis startTime endTime |> Num.toStr
            parseTime = Utc.now!
            dict = s |> parse
            parseEndTime = Utc.now!
            runTime = Utc.deltaAsMillis parseTime parseEndTime |> Num.toStr
            Stdout.line! "Dict length: $(Dict.len dict |> Num.toStr)"
            Stdout.line! "File read in $(readTime)ms\nFile parsed in $(runTime)ms"

        Err _ -> Stdout.line! "Failed to read file"

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
