#!/usr/bin/python

import sys, getopt, csv

def main(argv):
   fin = ''
   fout = ''

   try:
	  opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
   except getopt.GetoptError:
   	print 'filter.py -i <inputfile> -o <outputfile>'
   	sys.exit(2)

   for opt, arg in opts:
   	 if opt == '-h':
   	 	print 'filter.py -i <inputfile> -o <outputfile>'
   	 	sys.exit()
   	 elif opt in ("-i", "--ifile"):
   	 	fin = arg
   	 elif opt in ("-o", "-ofile"):
   	 	fout = arg

   reader = csv.reader(open(fin,'rb'), delimiter=',')
   filtered = filter(lambda row: float(row[1]) > 99.0, reader)
   csv.writer(open(fout, 'w'), delimiter=',').writerows(filtered)

if __name__ == "__main__":
	main(sys.argv[1:])