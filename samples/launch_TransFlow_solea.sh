#! /usr/bin/env bash
module load autoflow
current_dir=`pwd`

OUTPUT_WORKFLOW=$SCRATCH'/leng/transcriptoma/exec'

TEMPLATES="../Templates/transcriptome_reference_Illumina_fish.txt,../Templates/transcriptome_assembly_Illumina.txt,../Templates/transcriptome_assembly_454_single.txt,../Templates/transcriptome_mix_assembly_454_single_Illumina.txt,../Templates/transcriptome_validation_454_single_Illumina.txt"


vars=`echo "
\\$kmers=[45;55],
\\$NT_COVERAGE_IN_CONTIG=10,
\\$key_organisms=D.rerio,
\\$FLN_DATABASE=vertebrates,
\\$ill_type=paired,
\\$read_illumina_not_paired=$current_dir/../assembly_reads/reads.fastq,
\\$read_illumina_pair_1=$current_dir/../assembly_reads/paired_1.fastq,
\\$read_illumina_pair_2=$current_dir/../assembly_reads/paired_2.fastq,
\\$read_454=$current_dir/../assembly_reads/reads_454.fastq,
\\$reference=$current_dir/../transcriptome_references/fasta_files,
\\$reads=$current_dir/../transcriptome_references/read_files,
\\$BUSCO_db_path=~busco/programs/x86_64/db/20180427/actinopterygii_odb9, 
\\$report_template=$current_dir/../Templates/assembly_report.erb
" | tr -d [:space:]`

if [ $1 == '1' ]; then
	AutoFlow -w $TEMPLATES  -o $OUTPUT_WORKFLOW -c 1 -s -V $vars $2
fi

if [ $1 == '2' ]; then
	flow_logger -e $OUTPUT_WORKFLOW -r all
fi

if [ $1 == 'r' ]; then
	echo "Relaunching failed jobs"
	flow_logger -e $OUTPUT_WORKFLOW -w -l
fi

