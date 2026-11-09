
#!/bin/bash

if [[ -z ${1:-} ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

ELEMENT_DATA=$(psql -X -q -t -A \
  --username=freecodecamp \
  --dbname=periodic_table \
  -v ON_ERROR_STOP=1 \
  -v element="$1" <<'SQL'
SELECT e.atomic_number, e.name, e.symbol, t.type,
       p.atomic_mass, p.melting_point_celsius,
       p.boiling_point_celsius
FROM elements AS e
JOIN properties AS p
  ON p.atomic_number = e.atomic_number
JOIN types AS t
  ON t.type_id = p.type_id
WHERE e.atomic_number::TEXT = :'element'
   OR e.symbol = :'element'
   OR e.name = :'element'
LIMIT 1;
SQL
)

if [[ -z $ELEMENT_DATA ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$ELEMENT_DATA"

printf "The element with atomic number %s is %s (%s). It's a %s, with a mass of %s amu. %s has a melting point of %s celsius and a boiling point of %s celsius.\n" \
  "$ATOMIC_NUMBER" "$NAME" "$SYMBOL" "$TYPE" "$MASS" "$NAME" "$MELTING" "$BOILING"
