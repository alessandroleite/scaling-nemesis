package exp;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;


public class ConsolidateExperiments 
{
	private static final String FIELD_SEPARATOR = ",";
	
	static String name(File path) 
	{
		String[] parts = path.getPath().split(File.separator);
		return parts[parts.length -1];
	}
	
	
	private static class Matrix implements Comparable<Matrix>
	{
		private final File dir;
		private final long size;
		private List<Result> results;
		
		public Matrix(File dir) 
		{
			this.dir = dir;
			this.size = Long.valueOf(name(dir));
		}

		public static Matrix[] valueOf(File[] dirs) throws IOException 
		{
			Matrix[] matrices = new Matrix[dirs.length];
			for (int i = 0; i < matrices.length; i++) 
			{
				matrices[i] = new Matrix(dirs[i]); 
				matrices[i].results = readLinesOfFiles(matrices[i].dir.listFiles(new CsvFilenameFilter()));
			}
			return matrices;
		}
		
		@Override
		public int compareTo(Matrix other) 
		{
			return (this.size < other.size) ? -1 : (size == other.size ? 0: 1);
		}
		
		public Result getResult(int index)
		{
			return this.results.get(index);
		}
	}
	
	private static class Frequency implements Comparable<Frequency>
	{
		private final long value;
		private final File path;
		private final Matrix[] matrices;
		
		public Frequency(File dir) throws IOException 
		{
			this.path = dir;
			String [] parts = path.getPath().split(File.separator);
			this.value = Long.valueOf(parts[parts.length -1]);
			matrices = Matrix.valueOf(dir.listFiles(new DirectoryFilter()));
		}

		@Override
		public int compareTo(Frequency other) 
		{
			return (this.value < other.value) ? -1 : (value == other.value ? 0: 1);
		}
		
		
		static Frequency valueOf(File file) throws IOException 
		{
			return new Frequency(file);
		}
		
		private void consolidate(List<Result> results) throws IOException
		{
			Collections.sort(results);
			final Result result = results.get(results.size() - 1);
			
			String path = result.file.getAbsolutePath();
			String[] pathParts = path.split(File.separator);
			File file = new File(result.file.getParent(), pathParts[pathParts.length - 2] + ".txt");
			
			consolidate(file, results);
		}
		
		private void consolidate(File destFile, List<Result> results) throws IOException
		{
			if (results!= null &&! results.isEmpty()) 
			{
				Collections.sort(results);
				final Result result = results.get(results.size() - 1);
				StringBuilder sb = new StringBuilder(header(results)).append("\n");
				
				for(int j = 0; j < result.numberOfLines; j++)
				{
					sb.append(j + 1);
					for (int k = 0; k < results.size() - 1; k++)
					{
						sb.append(results.get(k).getLine(j));
					}
					sb.append(result.getLine(j)).append("\n");
				}
				writeFile(destFile, sb.toString());
			}
		}
		
		private void consolidateResultsByTime() throws IOException
		{
			if (this.matrices!= null && matrices.length > 0)
			{
				for(int i = 0; i < matrices.length; i++)
				{
					consolidate(matrices[i].results);
				}
			}
		}
		
		private void consolidateResultsByMatrixSize() throws IOException
		{
			if (this.matrices!= null && matrices.length > 0)
			{
				List<Result> results = new ArrayList<ConsolidateExperiments.Result>();
//				for (int i = 0; i < matrices.length; i++)
//				{
					Matrix matrix = matrices[0];
					
					for(int j = 0; j < matrix.results.size();j++)
					{
						Result r = matrix.getResult(j);
						results.add(r);
						for (int k = 1; k < matrices.length; k++)
						{
							results.add(matrices[k].getResult(j));
						}
						
						final File file = new File(this.path.getAbsolutePath(), String.format("%s.txt", r.name));
						consolidate(file, results);
						results.clear();
					}
				}
//			}
		}
		
		private static String header(List<Result> results) 
		{
			StringBuilder sb = new StringBuilder("time");
			for (int i = 0; i < results.size(); i++) 
			{
				sb.append(FIELD_SEPARATOR).append("w" + (i+1));
			}
			return sb.toString();
		}
		
	}
	
	static class Result implements Comparable<Result>
	{
		private final int numberOfLines;
		private final String[] lines;
		private final File file;
		private final String name;

		public Result(File f, String[] fileLines) 
		{
			this.file = f;
			this.lines = fileLines;
			this.numberOfLines = lines.length;
			
			String[] parts = file.getAbsolutePath().split(File.separator);
			this.name = parts[parts.length - 1].substring(0, parts[parts.length - 1].indexOf('.'));
		}

		@Override
		public int compareTo(Result other) 
		{
			return (this.numberOfLines < other.numberOfLines) ? -1 : (numberOfLines == other.numberOfLines ? 0: 1);
		}

		public String getLine(int i) 
		{
			String[] fields = i < numberOfLines ? lines[i].split(FIELD_SEPARATOR) : new String[]{};
			String content = fields.length > 1 ? lines[i].split(FIELD_SEPARATOR)[1] : " ";
			return new StringBuilder(FIELD_SEPARATOR).append(content).toString();
		}
		
		@Override
		public String toString() 
		{
			return String.format("%s - %s - %s\n", name, numberOfLines, file.getAbsolutePath());
		}
	}
	
	static class CsvFilenameFilter implements FilenameFilter
	{
		@Override
		public boolean accept(File dir, String name) 
		{
			return name.endsWith("csv");
		}
	}
	
	static class DirectoryFilter implements FileFilter
	{
		@Override
		public boolean accept(File pathname) 
		{
			return pathname.isDirectory();
		}
	}

	private static List<Result> readLinesOfFiles(File[] files) throws IOException
	{
		List<Result> contents = new ArrayList<Result>();
		
		for(File f: files)
		{
			contents.add(new Result(f, readLines(f)));
		}
		
		return contents;
	}

	private static String[] readLines(File f) throws IOException 
	{
		StringBuilder sb = new StringBuilder();
		BufferedReader bis = null;
		
		try
		{
			bis = new BufferedReader(new FileReader(f));
			String line;
			
			while ((line = bis.readLine()) != null)
			{
				if (!line.trim().isEmpty())
				{
					sb.append(line).append("\n");
				}
			}
		}finally
		{
			if (bis != null)
			{
				bis.close();
			}
		}
		return sb.toString().split("\n");
	}
	
	
	private static void consolidate(File dir) throws IOException
	{
		List<Frequency> frequencies = new ArrayList<ConsolidateExperiments.Frequency>();
		
		for(File freq: dir.listFiles(new DirectoryFilter()))
		{
			Frequency frequency = Frequency.valueOf(freq);
			frequency.consolidateResultsByTime();
			frequency.consolidateResultsByMatrixSize();
			frequencies.add(frequency);
		}
	}

	private static void writeFile(File newFile, String content) throws IOException 
	{
		FileWriter writer = null;
		try
		{
			writer = new FileWriter(newFile);
			writer.write(content);
			writer.flush();
		} finally
		{
			if (writer != null)
			{
				writer.close();
			}
		}
	}

	public static void main(String[] args) throws IOException
	{
		consolidate(new File(args[0]));
	}
}
