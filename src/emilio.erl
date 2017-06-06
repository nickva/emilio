% Licensed under the Apache License, Version 2.0 (the "License"); you may not
% use this file except in compliance with the License. You may obtain a copy of
% the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
% License for the specific language governing permissions and limitations under
% the License.

-module(emilio).


-export([
    main/1
]).


-include("emilio.hrl").


-define(OPTIONS, [
    {
        help,
        $h,
        "help",
        'boolean',
        "Show this help message"
    },
    {
        config,
        $c,
        "config",
        'string',
        "The config file to use [default: emilio.cfg]"
    },
    {
        jobs,
        $j,
        "jobs",
        'integer',
        "Number of files to process in parallel [default: 4]"
    },
    {
        report_formatter,
        $f,
        "format",
        'string',
        "Set the output format [default: text]"
    }
]).


main(Argv) ->
    case getopt:parse(?OPTIONS, Argv) of
        {ok, {Opts, Args}} ->
            execute(Opts, Args);
        _ ->
            usage(1)
    end.


execute(Opts, Args) ->
    case lists:keyfind(help, 1, Opts) of
        {help, true} ->
            usage(0);
        _ ->
            run(Opts, Args)
    end.


usage(Status) ->
    Name = escript:script_name(),
    Extra = "path [path ...]",
    Help = [
        {"path", "Paths to process, directories are searched recursively"}
    ],
    getopt:usage(?OPTIONS, Name, Extra, Help),
    emilio_util:shutdown(Status).


run(Opts, Args) ->
    emilio_cfg:compile(Opts),
    emilio_report:start_link(),
    process(Args, []).


process([], _Jobs) ->
    {ok, Count} = emilio_report:wait(),
    Status = if
        Count == 0 -> 0;
        true -> 2
    end,
    emilio_util:shutdown(Status);

process([Path | Rest], Jobs) ->
    NewJobs = emilio_path:walk(Path, fun process_file/2, Jobs),
    process(Rest, NewJobs).


process_file(FileName, Jobs) ->
    case filename:extension(FileName) of
        ".erl" -> run_checks(FileName);
        ".hrl" -> run_checks(FileName);
        _ -> ok
    end,
    Jobs.


run_checks(FileName) ->
    put(emilio_curr_file, FileName),
    emilio_report:queue(FileName),
    Tokens = emilio_pp:file(FileName),
    lists:foreach(fun(Check) ->
        Check:run(Tokens)
    end, ?EMILIO_CHECKS),
    emilio_report:finish(FileName).
