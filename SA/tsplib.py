from bs4 import BeautifulSoup
import numpy as np
import xml.etree.ElementTree as ET

def distance_matrix(xml_fname):
    f = open(xml_fname)
    bs = BeautifulSoup(f.read(), features="xml")
    vertices = bs.graph.findAll("vertex")
    
    n = len(vertices)
    distances = np.zeros((n,n))
    
    for i in range(n):
        vertex = vertices[i]
        for edge in vertex.findAll("edge"):
            j = int(edge.text)
            distances[i,j] = float(edge.get("cost"))
    f.close()
    return distances

def city_coordinates(filename):
    tree = ET.parse(filename)
    root = tree.getroot()
    coords = []
    for city in root.findall(".//city"):
        x = float(city.get("x"))
        y = float(city.get("y"))
        coords.append([x, y])
    return np.array(coords)