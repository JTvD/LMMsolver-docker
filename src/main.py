"""R2py introduction: https://rpy2.github.io/doc/v2.9.x/html/introduction.html"""
# import rpy2's package module
import rpy2.robjects.packages as rpackages
# R vector of strings
from rpy2.robjects.vectors import StrVector
# Package import
from rpy2.robjects.packages import importr
# Pandas dataframe to R dataframe conversion
from rpy2.robjects import pandas2ri
import rpy2.robjects as robjects
import pandas as pd
# Import the LMM solver
lmmsolver = importr('LMMsolver')
# Defining the R script and loading the instance in Python
r = robjects.r
r_source = robjects.r['source']
r_source('rfunctions.R')
compute_spline = robjects.globalenv['compute_spline']


def install_r_packages(packagenames: list):
    """Install the r packages from a list of strings"""

    # import R's utility package
    utils = rpackages.importr('utils')
    # select a mirror for R packages
    utils.chooseCRANmirror(ind=1)  # select the first mirror in the list

    # Install only not installed packages
    names_to_install = [x for x in packagenames if not rpackages.isinstalled(x)]
    if len(names_to_install) > 0:
        utils.install_packages(StrVector(names_to_install))


def r_compute_spline(df: pd.DataFrame, plant_identifier: str, trait_list: list):
    # Converting the dataframe into an R object for passing into R function
    with (robjects.default_converter + pandas2ri.converter).context():
        df_r = robjects.conversion.get_conversion().py2rpy(df)

    # Invoking the R function and getting the result
    df_result_r = compute_spline(df_r, plant_identifier, trait_list)
    # Converting it back to a pandas dataframe.
    with (robjects.default_converter + pandas2ri.converter).context():
        df_result = robjects.conversion.get_conversion().rpy2py(df_result_r)
    return df_result


if __name__ == "__main__":
    package_list = ['openssl', 'units', 's2', 'sf', 'LMMsolver']
    install_r_packages(package_list)

    df = pd.read_csv('test_data/cropreporter_traits.csv')
    trait_list = ['mean_yii', 'MeanChlorophyll', 'MeanNdvi', 'MeanEgreen', 'MeanPsri', 'MeanAri', 'MeanMari']
    predictions = r_compute_spline(df, 'PlantId', trait_list)

    # Look at some results
    # print(predictions[predictions['PlantId'] =='NPEC52.20230605.BD22.CE3027.Control.2'])
    print(predictions[predictions['PlantId'] == predictions['PlantId'].unique()[1]])
