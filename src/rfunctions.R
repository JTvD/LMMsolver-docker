# Function which uses the LMM solver to compute the spline.
library(LMMsolver)



##------------------------------------------------------------
# Inputs:
# - Dataframe with all the data
# - The unique identified for a specific plant
# - A list of traits to fir a spline for
# Return:
# - A list with predictions for all days in the meassuring period
##------------------------------------------------------------
compute_spline <- function(df, plant_identifier, trait_list)
{
    # Converting to datetime object
    df[['Datetime']] <- as.POSIXct(df[['Datetime']], format = "%Y-%m-%d, %H:%M:%OS", tz="Europe/Paris")
    # Datenum stored as integer, exact datetime of measurement
    df[['datenum']] <- as.integer(df[['Datetime']])
    # Date is multiplied with 86400 to get value at 00:00:00 of each day
    df[['date']] <- as.numeric(as.Date(df[['Datetime']]))


  ### Fit 1D spline per plant
  for (i in c(1:length(unique(df[[plant_identifier]])))){
    plant_id = unique(df[[plant_identifier]])[i]
    one_plant <- df[df[[plant_identifier]] == plant_id,]
    datenum = one_plant[['datenum']]
    preddates <- data.frame(datenum = min(one_plant$date):max(one_plant$date))
    # Each day has 24*60*60 = 86400 hours
    preddates <- preddates * 86400

    # Fit 1D spline per trait
    for (trait in trait_list){
      # Check for inf values
      if (sum(is.infinite(one_plant[[trait]])) > 0) {
        print(paste('Warning: infinite value encoutered for plant: ', plant_id, ', trait: ',trait))
      }
      trait_df <- one_plant[!is.infinite(one_plant[[trait]]),]
      # Need at least 2 not inf values
      # Need at least 2 not inf values
      if (nrow(trait_df) > 2) {
        # Nan values will be removed, but they do cause warnings.
        m1 <- LMMsolve(fixed = as.formula(paste(trait, "~", 1)),
                       spline = ~spl1D(x = datenum, nseg = 20),
                       data = trait_df)
        #summary(m1)

        # Note, in some cases you might only want to predict from the first meassurement to the last.
        # Especially when the first/last one was a nan.
        prediction <- obtainSmoothTrend(m1, newdata = preddates,
                                        includeIntercept = T)
        # Rename ypred column
        names(prediction)[names(prediction) == 'ypred'] <- trait
      } else {
        print(paste('Warning: not enough values to process plant: ', plant_id, ', trait: ',trait))
        prediction <- preddates
        prediction[trait] <- NA
      }
      prediction <- prediction[,c("datenum",trait)]
      # Combine results
      if (trait == trait_list[1]){
        plant_predictions <- prediction
      } else {
        plant_predictions <- merge(plant_predictions, prediction, by='datenum')
      }
    }
    plant_predictions[[plant_identifier]] = plant_id
    if (i == 1){
      all_predictions <- plant_predictions
    } else {
      all_predictions <- rbind(all_predictions, plant_predictions)
    }
  }

  # Convert time back to datetime, trick question is this datetime now UTC or Amsterdan local time?
  all_predictions[['Datetime']] <- as.POSIXct(all_predictions[['datenum']], origin="1970-01-01", tz = "UTC")

  return(all_predictions)
}


