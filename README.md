# suggested ndjson corpus source:

gutenberg-poetry-corpus


# USAGE:

╰$ CHECK=true ./piem_generator.rb piems_out/test.txt
╭─darius@darius-mbp in ~/src/piems
╰$ MINIMUM_MATCH_LENGTH=6 PROGRESS=true ./piem_generator.rb corpus.ndjson

You can then attempt to "fill in" shorter sequences like this:

MINIMUM_MATCH_LENGTH=3 CANDIDATES={output file such as piems_out/piem_12345.txt} ./piem_generator.rb corpus.ndjsontesting testing
