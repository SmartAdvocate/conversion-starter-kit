import os
from read_yaml_metadata import read_yaml_metadata
from sa_conversion_utils.utils.logging.setup_logger import setup_logger

logger = setup_logger(__name__, log_file="actions.log")

def generate_readmes_for_sql_files(sql_dir):
    """
    Generate a _README.md file in every directory that contains .sql files.

    Args:
        sql_dir (str): Path to the directory containing .sql files.
    """
    for dirpath, _, filenames in os.walk(sql_dir):
        # Skip directories that start with an underscore
        if any(part.startswith("_") for part in dirpath.split(os.sep)):
            continue

        # Find all .sql files in sql_dir
        sql_files = [f for f in filenames if f.lower().endswith(".sql")]

        if sql_files:
            readme_path = os.path.join(dirpath, "_README.md")
            relative_path = os.path.relpath(dirpath, sql_dir)

            # Generate content for the README.md file
            content = f"# {relative_path.replace(os.sep, ' ').title()}\n\n"
            # content += "| Script Name | Description |\n"
            # content += "|-------------|-------------|\n"
            content += "| Script Name | Description | Dependencies |\n"
            content += "|-------------|-------------|-------------|\n"
            for sql_file in sorted(sql_files):
                
                # Read metadata from the YAML file associated with the SQL file
                file_path = os.path.join(dirpath, sql_file)
                metadata = read_yaml_metadata(file_path)
                # print(f"{sql_file} metadata: {metadata} ({type(metadata)})")
                if metadata:
                    if isinstance(metadata, dict):
                        description = metadata.get("description", "No metadata found")
                        dependencies = metadata.get("dependencies", "No metadata found")
                    else:
                        description = getattr(metadata, "description", "No metadata found")
                        dependencies = getattr(metadata, "dependencies", "No metadata found")
                else:
                    description = "No metadata found"
                    dependencies = "No metadata found"
                # dependencies = metadata.get("dependencies", "") if metadata else "No metadata found"

                # content += f"| {sql_file} | {description} |\n"
                content += f"| {sql_file} | {description} | {dependencies} |\n"

            # Write the content to the README.md file
            with open(readme_path, "w", encoding="utf-8") as readme_file:
                readme_file.write(content)

            print(f"Created {readme_path}")

if __name__ == "__main__":
    # Define the root directories for SQL files
    sql_dirs = [
        r'litify\conversion',
        r'needles\conversion',
        r'needles-5\conversion',
        r'needles-neos\conversion'
    ]

    # Iterate over each directory and generate README.md files
    for sql_dir in sql_dirs:
        if os.path.exists(sql_dir):
            print(f"Processing directory: {sql_dir}")
            generate_readmes_for_sql_files(sql_dir)
        else:
            print(f"Directory does not exist: {sql_dir}")