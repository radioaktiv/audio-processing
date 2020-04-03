%include "settings.liq"
set("server.telnet.port", 8085)

mannheim_studio = input.jack(
  id="mannheim_studio"
)

mobil_1_harbor = input.harbor(
  id="mobil_direkt_1_harbor",
  port=8080,
  replay_metadata=false,
  "mobil_1"
)

mobil_1_safe = mksafe(mobil_1_harbor, id="mobil_1_safe")

mobil_1_blank = ref true

mobil_1_on_blank = on_blank(
  id="mobil_1_blank_detection",
  max_blank=60.,
  min_noise=0.5,
  start_blank=true,
  track_sensitive=false,
  on_noise = {
    log("on_noise called")
    mobil_1_blank := false
    log("set blank to false")
  },
  {
    log("on_blank called")
    mobil_1_blank := true;
    log("set blank to true")
  },
  mobil_1_safe
)

mobil_1_dummy = output.dummy(mobil_1_on_blank, id="mobil_1_dummy")

server.register(
  "mobil_1_blank",
  fun (arg) -> begin
    print(arg)
    "mobil_1 is currently " ^ (
      if !mobil_1_blank then
        "blank"
      else
        "noisy"
      end
    )
  end
)

source_name = interactive.string("active_source", "mannheim")

switched = switch(
  track_sensitive=false,
  [
    (
      {
        (not !mobil_1_blank) and (source_name() == "mobil_1")
      },
      mobil_1_on_blank
    ),
    ({true}, mannheim_studio)
  ],
  id="sende_switch"
)

output.jack(
  id="sendepre",
  switched
)
