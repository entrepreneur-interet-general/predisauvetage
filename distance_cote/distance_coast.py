#FInd distance to the coast of CROSS operation
import pandas as pd
import geopandas as gpd
from shapely.geometry import Polygon, Point, LinearRing

operations = pd.read_csv("operations.csv")

geometry = [Point(xy) for xy in zip(operations.longitude, operations.latitude)]
crs = {'init': 'epsg:4326'}
gdf = gpd.GeoDataFrame(operations, crs=crs, geometry=geometry)

cote = gpd.read_file("metropole-et-outre-mer.geojson")
poly = cote.geometry

#Cette projection ne fonctionne clairement pas
gdf2 = gdf.to_crs(epsg=3035)
poly2 = poly.to_crs(epsg=3035)

def min_distance(point):
    dist = poly2.distance(point).min()
    dist_km = dist/1000
    return dist

 gdf2['min_dist_to_lines'] = gdf2.geometry.apply(min_distance)