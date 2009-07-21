namespace DataSetViewer
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.dgSchema = new System.Windows.Forms.DataGridView();
            this.cbTable = new System.Windows.Forms.ComboBox();
            this.cbProviders = new System.Windows.Forms.ComboBox();
            ((System.ComponentModel.ISupportInitialize)(this.dgSchema)).BeginInit();
            this.SuspendLayout();
            // 
            // dgSchema
            // 
            this.dgSchema.AllowUserToAddRows = false;
            this.dgSchema.AllowUserToDeleteRows = false;
            this.dgSchema.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgSchema.Location = new System.Drawing.Point(12, 48);
            this.dgSchema.Name = "dgSchema";
            this.dgSchema.ReadOnly = true;
            this.dgSchema.Size = new System.Drawing.Size(731, 511);
            this.dgSchema.TabIndex = 0;
            // 
            // cbTable
            // 
            this.cbTable.FormattingEnabled = true;
            this.cbTable.Location = new System.Drawing.Point(356, 12);
            this.cbTable.Name = "cbTable";
            this.cbTable.Size = new System.Drawing.Size(387, 21);
            this.cbTable.TabIndex = 1;
            this.cbTable.SelectedIndexChanged += new System.EventHandler(this.cbTable_SelectedIndexChanged);
            // 
            // cbProviders
            // 
            this.cbProviders.FormattingEnabled = true;
            this.cbProviders.Location = new System.Drawing.Point(12, 11);
            this.cbProviders.Name = "cbProviders";
            this.cbProviders.Size = new System.Drawing.Size(317, 21);
            this.cbProviders.TabIndex = 2;
            this.cbProviders.SelectedIndexChanged += new System.EventHandler(this.cbProviders_SelectedIndexChanged);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(755, 571);
            this.Controls.Add(this.cbProviders);
            this.Controls.Add(this.cbTable);
            this.Controls.Add(this.dgSchema);
            this.Name = "Form1";
            this.Text = "Form1";
            this.Resize += new System.EventHandler(this.Form1_Resize);
            this.ResizeEnd += new System.EventHandler(this.Form1_ResizeEnd);
            ((System.ComponentModel.ISupportInitialize)(this.dgSchema)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.DataGridView dgSchema;
        private System.Windows.Forms.ComboBox cbTable;
        private System.Windows.Forms.ComboBox cbProviders;
    }
}

