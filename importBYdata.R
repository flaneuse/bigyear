source('~/GitHub/llamar/themes_ldh.r')

# Read in data ------------------------------------------------------------
url = 'https://docs.google.com/spreadsheets/d/1RWZuaNEqARhlfzXK-ZvKhm3RwNSFpirFXfSRnuFB25o/pub?output=csv'
# Note: sheet must be published to the web for connection to work.

bigyearWS = url %>% gs_url(visibility = 'private')

mj = bigyearWS %>% 
  gs_read(ws = 1) %>% 
  mutate(team = 'Michael and Jing')

nr = bigyearWS %>% 
  gs_read(ws = 2) %>% 
  mutate(team = 'Nancy and Rich')

l = bigyearWS %>% 
  gs_read(ws = 3) %>% 
  mutate(team = 'Laura')


# Clean up the data -------------------------------------------------------
# Merge datasets together
by = bind_rows(mj, nr, l) %>% 
  transmute(team = team,
            species = str_to_lower(Species), # Strip out upper case chars
            sex = `Sex..if.known.`,
            location = str_to_lower(Location),
            state = str_to_upper(State),
            loc = paste(location, state),
            date = Date)

# Convert places to GPS coords.
gps = geocode(by$loc, output = 'latlona')

# Displace data from houses.

# Fix weird geocoords & merge into
# Check states are states.
# Check birds are unique

# Count unique species ----------------------------------------------------
cumBirds = by %>% 
  count(team, date) %>% 
  mutate(numBirds = cumsum(n))

ggplot(cumBirds, aes(x = date, y = numBirds, 
                     group = team, colour = team)) +
  geom_point()
