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
bigyear = bind_rows(mj, nr, l) %>% 
  transmute(team = team,
            species = str_to_title(Species), # Strip out upper case chars
            species = str_trim(species), # Trim extra spaces, if they exist
            sex = `Sex..if.known.`,
            location = str_to_lower(Location),
            state = str_to_upper(State),
            loc = paste(location, state),
            date = mdy(Date))

bigyear = left_join(bigyear, birdDB, bigyear = c("species" = "commonName"))
# Convert places to GPS coords.
gps = geocode(bigyear$loc, output = 'latlona')

# Displace data from houses.

# Fix weird geocoords & merge into
# Check states are states.
# Check birds are unique

# Count unique species ----------------------------------------------------
begDate = as.Date('2015-12-26')
endDate = today()

numDays = as.period(interval(begDate, endDate), units = 'days')
numDays = numDays$day + 1

fullTimeRange = ymd(seq.Date(begDate, endDate, by = 'days'))

fullTimeRange = data.frame(team = 
                             c(rep('Michael and Jing', numDays),
                               rep('Nancy and Rich', numDays),
                               rep('Laura', numDays)),
                           date = rep(fullTimeRange, 3)) %>% 
  mutate(n = 0)

cumBirds = bigyear %>% 
  count(team, date) 

cumBirds2 = bind_rows(cumBirds, fullTimeRange) %>% 
  group_by(team, date) %>% 
  summarise(n = sum(n)) %>% 
  mutate(numBirds = cumsum(n))

ggplot(cumBirds2, aes(x = date, y = numBirds, 
                     group = team, colour = team)) +
  geom_line()
