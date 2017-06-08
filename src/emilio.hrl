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

-define(EMILIO_CHECKS, [
    emilio_check_line_length,
    emilio_check_ws_spaces_only,
    emilio_check_ws_file_newline,
    emilio_check_ws_space_after_comma,
    emilio_check_indents_counts,
    emilio_check_indents,
    emilio_check_indents_match,
    emilio_check_indents_clauses,
    emilio_check_indents_when
]).


-define(EMILIO_FILE_KEY, emilio_curr_file).


-define(EMILIO_REPORT(Anno, Code),
        emilio_report:update(
                get(?EMILIO_FILE_KEY), ?MODULE, Anno, Code, undefined)).

-define(EMILIO_REPORT(Anno, Code, Arg),
        emilio_report:update(
                get(?EMILIO_FILE_KEY), ?MODULE, Anno, Code, Arg)).
